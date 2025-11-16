SocialApp
=========

An iOS application for discovering events, managing tickets, and connecting people.  
This repository is currently under active development.

[![Issues][issues-shield]][issues-url]
[![Stars][stars-shield]][stars-url]
[![License][license-shield]][license-url]


Table of Contents
-----------------

- [About the Project](#about-the-project)
- [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)


About the Project
-----------------

SocialApp is a native iOS app focused on social experiences around events and tickets.  
The goal of this project is to explore a modern SwiftUI architecture, clean separation of modules, and a great user experience for event discovery and ticket management.


Built With
----------

- Swift
- SwiftUI
- Combine / async-await
- Tuist for project generation


Getting Started
---------------

To get a local copy up and running, follow these simple steps.


### Prerequisites

- Xcode 15 or later
- iOS 17 SDK or later
- macOS with the latest Xcode command line tools installed


### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/socialapp.git
   cd socialapp
   ```

2. Install Tuist

If you don't have Tuist installed:

```bash
# Via curl (recomendado)
curl -Ls https://install.tuist.io | bash

# Or via Homebrew
brew install tuist/tuist/tuist
```

### 3. Configure the project

```bash
cd SocialApp

# Generate xworkspace on Xcode
tuist generate
```

### 4. Open project

```bash
open SocialApp.xcworkspace
```

5. Select the `SocialApp` scheme and run the app on a simulator or device.

### Utils Commands

```bash
# Generate workspace
tuist generate

# Clean cache and generate
tuist clean
tuist install
tuist generate

# Execute tests
tuist test

# Verify dependencies
tuist graph
```

Contributing
------------

Contributions are what make the open-source community such an amazing place to learn, inspire, and create.  
Any contributions you make are **greatly appreciated**.

If you want to contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m "Add amazing feature"`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


License
-------

The license for this project is not defined yet.  
Before making the project public as open source, a proper license file (for example, MIT or Apache 2.0) should be added to this repository.


Contact
-------

If you have questions, suggestions, or feedback, please open an issue in this repository.  
Issues are the preferred way to discuss bugs, improvements, and ideas for the project.


[issues-shield]: https://img.shields.io/github/issues/yourusername/socialapp.svg?style=for-the-badge
[issues-url]: https://github.com/yourusername/socialapp/issues
[stars-shield]: https://img.shields.io/github/stars/yourusername/socialapp.svg?style=for-the-badge
[stars-url]: https://github.com/yourusername/socialapp/stargazers
[license-shield]: https://img.shields.io/github/license/yourusername/socialapp.svg?style=for-the-badge
[license-url]: https://github.com/yourusername/socialapp/blob/main/LICENSE


