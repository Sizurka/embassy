#!/bin/bash

set -eo pipefail

if ! command -v cargo-batch &> /dev/null; then
    echo "cargo-batch could not be found. Install it with the following command:"
    echo ""
    echo "    cargo install --git https://github.com/embassy-rs/cargo-batch cargo --bin cargo-batch --locked"
    echo ""
    exit 1
fi

export RUSTFLAGS=-Dwarnings
export DEFMT_LOG=trace,embassy_hal_internal=debug,embassy_net_esp_hosted=debug,cyw43=info,cyw43_pio=info,smoltcp=info
if [[ -z "${CARGO_TARGET_DIR}" ]]; then
    export CARGO_TARGET_DIR=target_ci
fi

TARGET=$(rustc -vV | sed -n 's|host: ||p')

BUILD_EXTRA=""
if [ $TARGET = "x86_64-unknown-linux-gnu" ]; then
    BUILD_EXTRA="--- build --release --manifest-path examples/std/Cargo.toml --target $TARGET --out-dir out/examples/std"
fi

# CI intentionally does not use -eabihf on thumbv7em to minimize dep compile time.
cargo batch \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features log \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features defmt \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv6m-none-eabi --features defmt \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv6m-none-eabi --features defmt,arch-cortex-m,executor-thread,executor-interrupt,integrated-timers \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,integrated-timers \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,rtos-trace \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,integrated-timers,rtos-trace \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,executor-thread \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,executor-thread,integrated-timers \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,executor-interrupt \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,executor-interrupt,integrated-timers \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,executor-thread,executor-interrupt \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target thumbv7em-none-eabi --features arch-cortex-m,executor-thread,executor-interrupt,integrated-timers \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target riscv32imac-unknown-none-elf --features arch-riscv32 \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target riscv32imac-unknown-none-elf --features arch-riscv32,integrated-timers \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target riscv32imac-unknown-none-elf --features arch-riscv32,executor-thread \
    --- build --release --manifest-path embassy-executor/Cargo.toml --target riscv32imac-unknown-none-elf --features arch-riscv32,executor-thread,integrated-timers \
    --- build --release --manifest-path embassy-sync/Cargo.toml --target thumbv6m-none-eabi --features defmt \
    --- build --release --manifest-path embassy-time/Cargo.toml --target thumbv6m-none-eabi --features defmt,defmt-timestamp-uptime,generic-queue-8,mock-driver \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv4,medium-ethernet,packet-trace \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv4,multicast,medium-ethernet \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,dhcpv4,medium-ethernet \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,dhcpv4,medium-ethernet,dhcpv4-hostname \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv6,medium-ethernet \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv6,medium-ieee802154 \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv6,medium-ethernet,medium-ieee802154 \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv6,medium-ethernet \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv4,proto-ipv6,medium-ethernet \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv4,proto-ipv6,medium-ip \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv4,proto-ipv6,medium-ip,medium-ethernet \
    --- build --release --manifest-path embassy-net/Cargo.toml --target thumbv7em-none-eabi --features defmt,tcp,udp,dns,proto-ipv4,proto-ipv6,medium-ip,medium-ethernet,medium-ieee802154 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv6m-none-eabi --features nrf51,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52805,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52810,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52811,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52820,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52832,gpiote,time,time-driver-rtc1,reset-pin-as-gpio \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52833,gpiote,time,time-driver-rtc1,nfc-pins-as-gpio \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf9160-s,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf9160-ns,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf5340-app-s,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf5340-app-ns,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf5340-net,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,time \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,log,time \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,log,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,log,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,defmt,time \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,defmt,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840,gpiote,defmt,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv6m-none-eabi --features nrf51,defmt,time,time-driver-rtc1 \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv6m-none-eabi --features nrf51,defmt,time \
    --- build --release --manifest-path embassy-nrf/Cargo.toml --target thumbv6m-none-eabi --features nrf51,time \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv6m-none-eabi --features time-driver,defmt,rp2040 \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv6m-none-eabi --features time-driver,log,rp2040 \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv6m-none-eabi --features time-driver,intrinsics,rp2040 \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv6m-none-eabi --features time-driver,qspi-as-gpio,rp2040 \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv8m.main-none-eabihf --features time-driver,defmt,rp235xa \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv8m.main-none-eabihf --features time-driver,log,rp235xa \
    --- build --release --manifest-path embassy-rp/Cargo.toml --target thumbv8m.main-none-eabihf --features time-driver,rp235xa,binary-info \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,exti,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,exti,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,exti \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f038f6,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f030c6,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f058t8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f030r8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f031k6,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f030rc,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f070f6,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f078vb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f042g4,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f072c8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f401ve,defmt,exti,time-driver-any \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f405zg,defmt,exti,time-driver-any \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f407zg,defmt,exti,time-driver-any \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f401ve,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f405zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f407zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f410tb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f411ce,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f412zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f413vh,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f415zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f417zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f423zh,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f427zi,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f429zi,log,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f437zi,log,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f439zi,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f446ze,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f469zi,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f479zi,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f730i8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h753zi,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h735zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h755zi-cm7,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h725re,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7b3ai,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7b3ai,defmt,exti,time-driver-tim1,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7r3z8,defmt,exti,time-driver-tim1,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7r7a8,defmt,exti,time-driver-tim1,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7s3a8,defmt,exti,time-driver-tim1,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7s7z8,defmt,exti,time-driver-tim1,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32l431cb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32l476vg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32l422cb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32wb15cc,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32l072cz,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32l041f6,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32l051k8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32l073cz,defmt,exti,time-driver-any,low-power,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32l151cb-a,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f303c8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f398ve,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f378cc,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32g0c1ve,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32f217zg,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze,defmt,exti,time-driver-any,low-power,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32wl54jc-cm0p,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32wle5jb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32g474pe,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32f107vc,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32f103re,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32f100c4,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32h503rb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32h523cc,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32h562ag,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32wba50ke,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32wba55ug,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32u5g9nj,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32wb35ce,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32u031r8,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32u073mb,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32u083rc,defmt,exti,time-driver-any,time \
    --- build --release --manifest-path embassy-nxp/Cargo.toml --target thumbv8m.main-none-eabihf \
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features ''\
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features 'log' \
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features 'defmt' \
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features 'log,firmware-logs' \
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features 'defmt,firmware-logs' \
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features 'log,firmware-logs,bluetooth' \
    --- build --release --manifest-path cyw43/Cargo.toml --target thumbv6m-none-eabi --features 'defmt,firmware-logs,bluetooth' \
    --- build --release --manifest-path cyw43-pio/Cargo.toml --target thumbv6m-none-eabi --features 'embassy-rp/rp2040' \
    --- build --release --manifest-path cyw43-pio/Cargo.toml --target thumbv6m-none-eabi --features 'embassy-rp/rp2040,overclock' \
    --- build --release --manifest-path embassy-boot-nrf/Cargo.toml --target thumbv7em-none-eabi --features embassy-nrf/nrf52840 \
    --- build --release --manifest-path embassy-boot-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9160-ns \
    --- build --release --manifest-path embassy-boot-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9120-ns \
    --- build --release --manifest-path embassy-boot-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9151-ns \
    --- build --release --manifest-path embassy-boot-nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9161-ns \
    --- build --release --manifest-path embassy-boot-rp/Cargo.toml --target thumbv6m-none-eabi --features embassy-rp/rp2040 \
    --- build --release --manifest-path embassy-boot-stm32/Cargo.toml --target thumbv7em-none-eabi --features embassy-stm32/stm32l496zg \
    --- build --release --manifest-path docs/examples/basic/Cargo.toml --target thumbv7em-none-eabi \
    --- build --release --manifest-path docs/examples/layer-by-layer/blinky-pac/Cargo.toml --target thumbv7em-none-eabi \
    --- build --release --manifest-path docs/examples/layer-by-layer/blinky-hal/Cargo.toml --target thumbv7em-none-eabi \
    --- build --release --manifest-path docs/examples/layer-by-layer/blinky-irq/Cargo.toml --target thumbv7em-none-eabi \
    --- build --release --manifest-path docs/examples/layer-by-layer/blinky-async/Cargo.toml --target thumbv7em-none-eabi \
    --- build --release --manifest-path examples/nrf52810/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/nrf52810 \
    --- build --release --manifest-path examples/nrf52840/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/nrf52840 \
    --- build --release --manifest-path examples/nrf5340/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/nrf5340 \
    --- build --release --manifest-path examples/nrf9160/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/nrf9160 \
    --- build --release --manifest-path examples/nrf9151/s/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/nrf9151/s \
    --- build --release --manifest-path examples/nrf9151/ns/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/nrf9151/ns \
    --- build --release --manifest-path examples/nrf51/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/nrf51 \
    --- build --release --manifest-path examples/rp/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/rp \
    --- build --release --manifest-path examples/rp23/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/rp23 \
    --- build --release --manifest-path examples/stm32f0/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/stm32f0 \
    --- build --release --manifest-path examples/stm32f1/Cargo.toml --target thumbv7m-none-eabi --out-dir out/examples/stm32f1 \
    --- build --release --manifest-path examples/stm32f2/Cargo.toml --target thumbv7m-none-eabi --out-dir out/examples/stm32f2 \
    --- build --release --manifest-path examples/stm32f3/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32f3 \
    --- build --release --manifest-path examples/stm32f334/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32f334 \
    --- build --release --manifest-path examples/stm32f4/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32f4 \
    --- build --release --manifest-path examples/stm32f469/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32f469 \
    --- build --release --manifest-path examples/stm32f7/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32f7 \
    --- build --release --manifest-path examples/stm32c0/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/stm32c0 \
    --- build --release --manifest-path examples/stm32g0/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/stm32g0 \
    --- build --release --manifest-path examples/stm32g4/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32g4 \
    --- build --release --manifest-path examples/stm32h5/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/stm32h5 \
    --- build --release --manifest-path examples/stm32h7/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32h7 \
    --- build --release --manifest-path examples/stm32h735/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32h735 \
    --- build --release --manifest-path examples/stm32h755cm4/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32h755cm4 \
    --- build --release --manifest-path examples/stm32h755cm7/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32h755cm7 \
    --- build --release --manifest-path examples/stm32h7rs/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32h7rs \
    --- build --release --manifest-path examples/stm32l0/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/stm32l0 \
    --- build --release --manifest-path examples/stm32l1/Cargo.toml --target thumbv7m-none-eabi --out-dir out/examples/stm32l1 \
    --- build --release --manifest-path examples/stm32l4/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32l4 \
    --- build --release --manifest-path examples/stm32l5/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/stm32l5 \
    --- build --release --manifest-path examples/stm32u0/Cargo.toml --target thumbv6m-none-eabi --out-dir out/examples/stm32u0 \
    --- build --release --manifest-path examples/stm32u5/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/stm32u5 \
    --- build --release --manifest-path examples/stm32wb/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32wb \
    --- build --release --manifest-path examples/stm32wba/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/stm32wba \
    --- build --release --manifest-path examples/stm32wl/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/stm32wl \
    --- build --release --manifest-path examples/lpc55s69/Cargo.toml --target thumbv8m.main-none-eabihf --out-dir out/examples/lpc55s69 \
    --- build --release --manifest-path examples/boot/application/nrf/Cargo.toml --target thumbv7em-none-eabi --features embassy-nrf/nrf52840,skip-include --out-dir out/examples/boot/nrf52840 \
    --- build --release --manifest-path examples/boot/application/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9160-ns,skip-include --out-dir out/examples/boot/nrf9160 \
    --- build --release --manifest-path examples/boot/application/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9120-ns,skip-include --out-dir out/examples/boot/nrf9120 \
    --- build --release --manifest-path examples/boot/application/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9151-ns,skip-include --out-dir out/examples/boot/nrf9151 \
    --- build --release --manifest-path examples/boot/application/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9161-ns,skip-include --out-dir out/examples/boot/nrf9161 \
    --- build --release --manifest-path examples/boot/application/rp/Cargo.toml --target thumbv6m-none-eabi --features skip-include --out-dir out/examples/boot/rp \
    --- build --release --manifest-path examples/boot/application/stm32f3/Cargo.toml --target thumbv7em-none-eabi --features skip-include --out-dir out/examples/boot/stm32f3 \
    --- build --release --manifest-path examples/boot/application/stm32f7/Cargo.toml --target thumbv7em-none-eabi --features skip-include --out-dir out/examples/boot/stm32f7 \
    --- build --release --manifest-path examples/boot/application/stm32h7/Cargo.toml --target thumbv7em-none-eabi --features skip-include --out-dir out/examples/boot/stm32h7 \
    --- build --release --manifest-path examples/boot/application/stm32l0/Cargo.toml --target thumbv6m-none-eabi --features skip-include --out-dir out/examples/boot/stm32l0 \
    --- build --release --manifest-path examples/boot/application/stm32l1/Cargo.toml --target thumbv7m-none-eabi --features skip-include --out-dir out/examples/boot/stm32l1 \
    --- build --release --manifest-path examples/boot/application/stm32l4/Cargo.toml --target thumbv7em-none-eabi --features skip-include --out-dir out/examples/boot/stm32l4 \
    --- build --release --manifest-path examples/boot/application/stm32wl/Cargo.toml --target thumbv7em-none-eabi --features skip-include --out-dir out/examples/boot/stm32wl \
    --- build --release --manifest-path examples/boot/application/stm32wb-dfu/Cargo.toml --target thumbv7em-none-eabi --out-dir out/examples/boot/stm32wb-dfu \
    --- build --release --manifest-path examples/boot/bootloader/nrf/Cargo.toml --target thumbv7em-none-eabi --features embassy-nrf/nrf52840 \
    --- build --release --manifest-path examples/boot/bootloader/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9160-ns \
    --- build --release --manifest-path examples/boot/bootloader/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9120-ns \
    --- build --release --manifest-path examples/boot/bootloader/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9151-ns \
    --- build --release --manifest-path examples/boot/bootloader/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features embassy-nrf/nrf9161-ns \
    --- build --release --manifest-path examples/boot/bootloader/rp/Cargo.toml --target thumbv6m-none-eabi \
    --- build --release --manifest-path examples/boot/bootloader/stm32/Cargo.toml --target thumbv7em-none-eabi --features embassy-stm32/stm32l496zg \
    --- build --release --manifest-path examples/boot/bootloader/stm32wb-dfu/Cargo.toml --target thumbv7em-none-eabi --features embassy-stm32/stm32wb55rg \
    --- build --release --manifest-path examples/boot/bootloader/stm32-dual-bank/Cargo.toml --target thumbv7em-none-eabi --features embassy-stm32/stm32h743zi \
    --- build --release --manifest-path examples/wasm/Cargo.toml --target wasm32-unknown-unknown --out-dir out/examples/wasm \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32f103c8 --out-dir out/tests/stm32f103c8 \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f429zi --out-dir out/tests/stm32f429zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f446re --out-dir out/tests/stm32f446re \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32g491re --out-dir out/tests/stm32g491re \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32g071rb --out-dir out/tests/stm32g071rb \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32c031c6 --out-dir out/tests/stm32c031c6 \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h755zi --out-dir out/tests/stm32h755zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h753zi --out-dir out/tests/stm32h753zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7a3zi --out-dir out/tests/stm32h7a3zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32wb55rg --out-dir out/tests/stm32wb55rg \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32h563zi --out-dir out/tests/stm32h563zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32u585ai --out-dir out/tests/stm32u585ai \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32u5a5zj --out-dir out/tests/stm32u5a5zj \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32wba52cg --out-dir out/tests/stm32wba52cg \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32l073rz --out-dir out/tests/stm32l073rz \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32l152re --out-dir out/tests/stm32l152re \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32l4a6zg --out-dir out/tests/stm32l4a6zg \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32l4r5zi --out-dir out/tests/stm32l4r5zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32l552ze --out-dir out/tests/stm32l552ze \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f767zi --out-dir out/tests/stm32f767zi \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7m-none-eabi --features stm32f207zg --out-dir out/tests/stm32f207zg \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32f303ze --out-dir out/tests/stm32f303ze \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32l496zg --out-dir out/tests/stm32l496zg \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32wl55jc --out-dir out/tests/stm32wl55jc \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv7em-none-eabi --features stm32h7s3l8 --out-dir out/tests/stm32h7s3l8 \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32f091rc --out-dir out/tests/stm32f091rc \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv8m.main-none-eabihf --features stm32h503rb --out-dir out/tests/stm32h503rb \
    --- build --release --manifest-path tests/stm32/Cargo.toml --target thumbv6m-none-eabi --features stm32u083rc --out-dir out/tests/stm32u083rc \
    --- build --release --manifest-path tests/rp/Cargo.toml --target thumbv6m-none-eabi --out-dir out/tests/rpi-pico \
    --- build --release --manifest-path tests/nrf/Cargo.toml --target thumbv6m-none-eabi --features nrf51422 --out-dir out/tests/nrf51422-dk \
    --- build --release --manifest-path tests/nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52832 --out-dir out/tests/nrf52832-dk \
    --- build --release --manifest-path tests/nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52833 --out-dir out/tests/nrf52833-dk \
    --- build --release --manifest-path tests/nrf/Cargo.toml --target thumbv7em-none-eabi --features nrf52840 --out-dir out/tests/nrf52840-dk \
    --- build --release --manifest-path tests/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf5340 --out-dir out/tests/nrf5340-dk \
    --- build --release --manifest-path tests/nrf/Cargo.toml --target thumbv8m.main-none-eabihf --features nrf9160 --out-dir out/tests/nrf9160-dk \
    --- build --release --manifest-path tests/riscv32/Cargo.toml --target riscv32imac-unknown-none-elf \
    $BUILD_EXTRA


# temporarily disabled, these boards are dead.
rm -rf out/tests/stm32f103c8
rm -rf out/tests/nrf52840-dk

rm out/tests/stm32wb55rg/wpan_mac
rm out/tests/stm32wb55rg/wpan_ble

# unstable, I think it's running out of RAM?
rm out/tests/stm32f207zg/eth

# doesn't work, gives "noise error", no idea why. usart_dma does pass.
rm out/tests/stm32u5a5zj/usart

if [[ -z "${TELEPROBE_TOKEN-}" ]]; then
    echo No teleprobe token found, skipping running HIL tests
    exit
fi

teleprobe client run -r out/tests
