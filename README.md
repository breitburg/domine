# Domine

Search domains with expressions. Insert numbers, letters, and any TLDs in one query with Domine. It uses reverse-engineered [Instant Domain Search](https://instantdomainsearch.com/) API, so it could break at any time.

```console
$ domine check "example.*" "[1-12]am.co" "pu[a-z]r.studio"
44 domains are available
✔ example.se   ✔ 2am.co    ✔ pulr.studio    ...
```

## Features

- **Numbers:** Interate from 1 to 12 with `domine check "[1-12]am.com"` to check domains such as `1am.com`, `2am.com`...
- **Letters:** Check the whole alphabet with `domine check "letter-[a-z].com"` for `letter-a.com`, `letter-b.com`...
- **Popular TLDs at once:** Use the asterisk symbol to check multiple TLDs at once with `domine check "domine.*"` for `domine.com`, `domine.org`...
- **Multiple queries:** Ask Domine to make multiple queries at one command `domine check "[1-12]am.com" "letter-[a-z].com"`.
- **Combine expressions:** Use `domine check "l[a-z]n[1-2].*"` to get `lan1.com`, `lan2.com`...

> Shout out to [Robert-Jan Keizer's `domainchecker`](https://github.com/KeizerDev/domainchecker) for some inspiration.

