# Domine

Search domains with expressions. Insert numbers, letters, and any TLDs in one query with Domine. It uses reverse-engineered [Instant Domain Search](https://instantdomainsearch.com/) API, so it could break at any time.

![Gif Preview](https://github.com/breitburg/domine/assets/25728414/71f50a81-ab89-426a-a0ad-500ad083b662)

## Installation

To install Domine without any additional steps, you can use a Docker:

```console
$ docker run breitburg/domine check "example [1-12]am.co"
```

Alternatively, if you have Dart installed, you can run the following command in your terminal:

```console
$ dart pub global activate domine
```

This command will install all the required dependencies and make `$ domine` accessible.

## Features

- **Numbers:** Interate from 1 to 12 with `domine check "[1-12]am.com"` to check domains such as `1am.com`, `2am.com`...
- **Letters:** Check the whole alphabet with `domine check "letter-[a-z].com"` for `letter-a.com`, `letter-b.com`...
- **Popular TLDs at once:** Use the asterisk symbol to check multiple TLDs at once with `domine check "domine.*"` for `domine.com`, `domine.org`...
- **Multiple queries:** Ask Domine to make multiple queries at one command `domine check "[1-12]am.com" "letter-[a-z].com"`.
- **Combine expressions:** Use `domine check "l[a-z]n[1-2].*"` to get `lan1.com`, `lan2.com`...

> Shout out to [Robert-Jan Keizer's `domainchecker`](https://github.com/KeizerDev/domainchecker) for some inspiration.
