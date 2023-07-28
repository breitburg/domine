# Domine

Search domains with expressions. Insert numbers, letters, and any TLDs in one query with Domine. It uses reverse-engineered [Instant Domain Search](https://instantdomainsearch.com/) API, so it could break at any time.

![Gif Preview](https://github.com/breitburg/domine/assets/25728414/71f50a81-ab89-426a-a0ad-500ad083b662)

> **Disclaimer**  
> Domine is good at giving accurate data about registered domains, but it may not have up-to-date information on unregistered domains. If you want the most reliable information, use [ICANN Lookup](https://lookup.icann.org/) for the right details.

## Installation

To use Domine without any installation, you can use Docker:

```console
$ docker run --rm --tty breitburg/domine check "example.com" "[1-12]am.co"
```

Alternatively, if you have Dart installed, you can run the following command in your terminal:

```console
$ dart pub global activate domine
$ domine check "example.com" "[1-12]am.co"
```

This command will install all the required dependencies and make `domine` accessible.

## Usage

You can always obtain information about commands by running `domine help`.

### Check

The `check` command allows you to perform domain checks on multiple domains simultaneously by including multiple queries:

```console
$ domine check "<query1>" "<query2>" ...
```

By utilizing expressions, you can check the availability and status of multiple domains at once.

It also supports headless mode. If you need to write all the available domains in a file, you can use `domine check "<query>" > domains.txt`.

#### Numbers

Iterate through any numbers using the `domine check "[1-12]am.com"` command to verify domains like `1am.com`, `2am.com`, and so on.

#### Letters

Check the entire alphabet (or any other range of letters) effortlessly with the `domine check "letter-[a-z].com"` command to validate domains like `letter-a.com`, `letter-b.com`, and more.

#### Popular TLDs at Once

Check multiple popular TLDs simultaneously. Use the asterisk symbol with the `domine check "domine.*"` command to verify domains such as `domine.com`, `domine.org`, and so forth.

> Shout out to [Robert-Jan Keizer's `domainchecker`](https://github.com/KeizerDev/domainchecker) for inspiration.

#### Multiple Queries

Perform multiple domain queries with a single command using the syntax `domine check "[1-12]am.com" "letter-[a-z].com"`.

#### Combine Expressions

Combine different patterns using the `domine check "l[a-z]n[1-2].*"` command to obtain domains like `lan1.com`, `lan2.com`, `lbn1.com` and more.

### AI

> Unstable. Work in progress.

You can use AI to generate ideas for domains and automatically check their availability. You can specify the maximum amount of available domains to be found using the `-l` or `--limit <number>` option.

All you need is an OpenAI API key, which you can provide using the `--openai-key` option or by setting it as an environment variable named `OPENAI_KEY`.

When you're ready, just use the following syntax:

```console
$ domine brainstorm "<prompt>"
```

Also, you can specify the model you want to use by providing the `--model <name>` option.

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
