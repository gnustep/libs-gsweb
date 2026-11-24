
# WebObjects load balancing

## The pieces

- **Web server adaptor**: a module in Apache (mod_WebObjects), IIS, or a CGI program. It sits between the browser and your apps, and **all load balancing happens here**. Application instances know nothing about each other.
- **Application instances**: each is a separate JVM process listening on its own port. Several instances of the same app (say `Store`) may run across several hosts.
- **wotaskd**: a daemon on each host that starts, stops, and monitors instances, and holds the site configuration (which apps, instances, hosts, and ports exist). **JavaMonitor** is the admin UI that edits that configuration.
- **The adaptor** gets the instance list from wotaskd and refreshes it periodically. When you add or remove instances, the adaptor eventually learns about it.

## Instance numbers

Each instance of an application has an integer **instance number** (1, 2, 3...), unique within that application. It's a logical ID rather than a port, and it appears in the URL:

```
/cgi-bin/WebObjects/Store.woa/3/wo/Xk29fj.../0.1.4
                             ^
                      instance number
```

This number is how a request tells the adaptor which instance it belongs to. If the URL has no instance number (or it's a wildcard), the adaptor is free to choose.

**Instance 0 means "any".** The backend emits session links with instance `0` (e.g. `/wo/Store.woa/0/wo/...`), which means "any instance". The adaptor treats `0` — and `-1` — the same as an absent instance number: the request is balanced like an unpinned one, and the forwarded request line is rewritten to carry the instance the adaptor actually chose. This matters for session links: the follow-up request must reach the instance that created the session, so the adaptor never forwards a `0` (or `-1`) to the backend as-is.

## Sessions and component actions

Sessions are held **in memory inside one instance**. Only that instance has your shopping cart, so subsequent requests must return to it. That is the core constraint on load balancing.

1. **First request** (no session, no instance number): the adaptor picks an instance using its balancing algorithm. That instance creates a session and generates the session ID.
2. **Every response** embeds the session ID and instance number in the URLs it generates, or in cookies (`wosid` and `woinst`) if cookies are enabled.
3. **Later requests** carry both values. The adaptor reads the instance number and routes the request straight to that instance, bypassing load balancing.

This is why the load balancer only really "balances" at session creation time. After that, the session is pinned to its instance.

## Direct actions

Direct actions use URLs like `/WebObjects/Store.woa/wa/ProductSearch?q=lamp`. The `/wa/` segment marks them. They are **stateless by default**: no session ID and no instance number in the URL.

- Each request is balanced independently, so consecutive requests can hit different instances. This spreads load much more evenly than session-bound traffic, and you can add or remove instances freely.
- If a direct action *does* use a session, the session ID is passed as `?wosid=...` (or via cookie), along with the instance number (`woinst`), so the adaptor can pin it to the right instance. The session still lives in one instance's memory, so the same stickiness applies.
- Public pages, search results, and RESTful endpoints should usually be direct actions, so they don't create sessions at all.

## Choosing an instance

For requests that aren't pinned, the adaptor uses a configurable algorithm, typically one of:

- **Round robin**: cycle through available instances.
- **Random**: pick one at random.
- **Load average**: prefer the instance reporting the lightest load. Instances report this back to the adaptor in response headers.

The adaptor skips instances it considers unavailable.

## Failure and special cases

- **Dead instance**: if the adaptor can't connect, it marks the instance dead for a period and routes new requests elsewhere. Anyone with a session on that instance has lost it, since it lived in that process's memory. They typically get a "session expired" page, and the adaptor sends them to a live instance, which starts fresh. Because of this, apps often store critical state in the database or use cookies for restoring state.
- **Refuse new sessions**: in JavaMonitor you can tell an instance to stop accepting *new* sessions. The adaptor stops sending it unpinned requests, but continues sending requests that carry its instance number, so existing users finish normally. This enables graceful rolling restarts and deployments. You can also set a maximum number of active sessions, after which the instance refuses new ones automatically.
- **Pinned request to a refusing or full instance**: pinned requests still go through, since the session already exists there.

## Summary

| Request type | Instance number present? | Who picks the instance? |
|---|---|---|
| First request / new session | No | Adaptor's algorithm |
| Component action with session | Yes (URL or `woinst` cookie) | Pinned to that instance |
| Component action with instance 0 / -1 | 0 or -1 ("any") | Adaptor's algorithm (balanced like unpinned) |
| Stateless direct action | No | Adaptor's algorithm, every time |
| Direct action with session | Yes (`wosid` + `woinst`) | Pinned to that instance |
| Direct action with instance 0 / -1 | 0 or -1 ("any") | Adaptor's algorithm (balanced like unpinned) |

we use a x-webobjects-loadaverage header in GNUstepWeb to send the load from the app instance to the adaptor
