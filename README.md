# zkfoundry-smoke-test


This repository contains smoke tests for `zkfoundry`, ensuring that the functionality remains robust and does not regress through changes. These tests serve as an early warning mechanism to catch issues that could affect the zk features of `foundry-zksync`.

## Getting Started

To run the smoke tests on your local environment, follow these steps:

### Prerequisites

- Ensure you have a compatible version of [Rust](https://www.rust-lang.org/tools/install) installed.
- Clone the [`foundry-zksync`](https://github.com/matter-labs/foundry-zksync) repository and ensure it is up to date and built.

### Installation

1. Clone the `zkfoundry-smoke-test` repository:
   ```bash
   git clone https://github.com/your-org/zkfoundry-smoke-test.git
   cd zkfoundry-smoke-test
   ```

2. Run against `foundry-zksync`
   ```bash
   zkforge zkbuild && zkforge test
   ```

## Contributing

Contributions to the `zkfoundry-smoke-test` suite are welcome. 

Before submitting PRs, please read the `CONTRIBUTING.md` file.

## License

This project is licensed under the [MIT License](LICENSE). For more details, see the `LICENSE` file in the root of the repository.