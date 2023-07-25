# Domine

Search domains with expressions. Insert numbers, letters, and any TLDs in one query with Domine. It uses reverse-engineered [Instant Domain Search](https://instantdomainsearch.com/) API, so it could break at any time.

![Gif Preview](https://github.com/breitburg/domine/assets/25728414/71f50a81-ab89-426a-a0ad-500ad083b662)

## Features

- **Numbers:** Interate from 1 to 12 with `domine check "[1-12]am.com"` to check domains such as `1am.com`, `2am.com`...
- **Letters:** Check the whole alphabet with `domine check "letter-[a-z].com"` for `letter-a.com`, `letter-b.com`...
- **Popular TLDs at once:** Use the asterisk symbol to check multiple TLDs at once with `domine check "domine.*"` for `domine.com`, `domine.org`...
- **Multiple queries:** Ask Domine to make multiple queries at one command `domine check "[1-12]am.com" "letter-[a-z].com"`.
- **Combine expressions:** Use `domine check "l[a-z]n[1-2].*"` to get `lan1.com`, `lan2.com`...

## Installation

To install Domine without any additional steps, you can use Docker:

```console
$ docker run breitburg/domine check "[1-12]am.co"
```

Alternatively, if you have Dart installed, you can run the following command in your terminal:

```console
$ dart pub global activate domine
```

This command will install all the required dependencies and make `domine` accessible.

> Shout out to [Robert-Jan Keizer's `domainchecker`](https://github.com/KeizerDev/domainchecker) for some inspiration.

## Contribution

Contributions to Domine are welcome! If you have any ideas, suggestions, bug reports, or feature requests, please feel free to open an issue on the [GitHub repository](https://github.com/breitburg/domine). 

If you'd like to contribute directly to the codebase, you can follow these steps:

1. Fork the repository and clone it to your local machine.
2. Create a new branch for your feature or bug fix: `git checkout -b my-branch`.
3. Make the necessary changes and additions.
4. Commit your changes: `git commit -m "Add feature or bug fix"`.
5. Push to your branch: `git push origin my-branch`.
6. Open a pull request on the main repository.

Please ensure that your contributions align with the project's coding style and guidelines. Your involvement helps improve Domine for everyone.
