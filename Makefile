all: riscv yocto riscy-ooo

riscv: .riscv.built
yocto: .yocto.built
riscy-ooo: .riscy-ooo.built

.riscv.built: riscv.Dockerfile
	docker build -f $< -t citadel_riscv:latest .
	touch $@

.yocto.built: yocto.Dockerfile
	docker build -f $< -t citadel_yocto:latest .
	touch $@

.riscy-ooo.built: riscy-ooo.Dockerfile
	docker build -f $< -t citadel_riscy-ooo:latest .
	touch $@
