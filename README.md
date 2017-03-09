![Needle](https://labs.mwrinfosecurity.com/assets/needle-logo-blue.jpg)


# Description

NeedleAgent is an open source iOS app complementary to [needle](https://github.com/mwrlabs/needle), the iOS security testing framework. It allows needle to programmatically perform tasks natively on the device eliminating the need for third party tools. The agent plays the role of a server which listens for TCP connections coming from needle (or any other TCP client).

The agent has certain messages (opcodes) that it will respond to, and, like needle, it is designed to be easily extensible: adding an opcode to the agent only requires one method to be written.


# Installation

See the [Installation Guide](https://github.com/mwrlabs/needle/wiki/Installation-Guide) in the main project Wiki for details.


# Usage

Usage instructions (for both standard users and contributors) can be found in the main [project Wiki](https://github.com/mwrlabs/needle/wiki).


# License

Needle-Agent is released under a 3-clause BSD License. See the `LICENSE` file for full details.


# Contact

Feel free to submit issues or ping us on Twitter - [@mwrneedle](https://twitter.com/mwrneedle), [@lancinimarco](https://twitter.com/lancinimarco)