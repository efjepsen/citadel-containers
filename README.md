# Citadel Containers

This repo contains docker containers for building Citadel-related binaries & hardware.

These containers are useful for personal development, and can be integrated into CI jobs for automated testing.

## Containers

- yocto: For building Linux images using `kas`
- riscv: riscv-toolchain already installed.
- riscy-ooo: Development environment for `riscy-ooo`, when needing to synthesize hardware.

## Usage

Containers are currently not pushed to any registry, so you need to `make` them on your own.

Choose to make just one container, e.g. `$ make riscv`, or all of them with `$ make all`.

To use the containers, add the `scripts` folder to your PATH, which can be done manually or by sourcing `export`:

```
$ . export
```

`with_*` scripts will execute a shell command inside the container. Commands need to be wrapped in qutoes:

```
$ with_yocto "kas build kas/base-riscv.yml"
```

`*_shell` scripts will present you with a shell inside the container.

```
$ yocto_shell
user@hostname: /enclaves
```

## TODO

- Probably combine riscv + yocto, and add `qemu-citadel` to the installed software. Then, you could build a linux image and run emulations with one container.
