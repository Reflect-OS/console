# ReflectOS Console

[![Test](https://github.com/Reflect-OS/console/actions/workflows/test.yml/badge.svg)](https://github.com/Reflect-OS/console/actions/workflows/test.yml)

## About

ReflectOS is the approachable, configurable, and extensible OS for your smart mirror project.  It is designed to allow anyone to easily install, customize, and enjoy a smart mirror/display - no coding or command line usage required!  Instructions for installing on your device and more details about ReflectOS can be found on the [ReflectOS Firmware](https://github.com/Reflect-OS/firmware) project.

This repo contains the web UI which is used to dynamically configure ReflectOS sections, layouts, and layout managers.  Like the rest of ReflectOS, it is written in Elixir and is built on [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/welcome.html).  

For more information on the components of the ReflectOS system, refer to the [ReflectOS Firmware](https://github.com/Reflect-OS/firmware) documentation.

If you are interested in building your own extensions for ReflectOS, 
please see the documentation for the [ReflectOS Kernel](https://hexdocs.pm/reflect_os_kernel) library and the examples which ship with the system by default in the [ReflectOS Core](https://hexdocs.pm/reflect_os_core) package.

## Contributing

Contributions are welcome for this project!  You can 
[open an issue](https://github.com/Reflect-OS/console/issues) to report a bug or request a feature enhancement.  Code contributions are also welcomed, and can be 
submitted by forking this repository and creating a pull request. 

## Local Development

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Learn more about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
