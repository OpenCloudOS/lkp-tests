require 'spec_helper'

describe 'kernel_selftests' do
  describe 'stats' do
    let(:stats_script) { "#{LKP_SRC}/stats/kernel_selftests" }

    it 'stats test results' do
      stdout = <<EOF
make: Entering directory '/usr/src/linux-selftests-x86_64-rhel-7.2-a121103c922847ba5010819a3f250f1f7fc84ab8/tools/testing/selftests/bpf'
selftests: test_kmod.sh [FAIL]
make: Leaving directory '/usr/src/linux-selftests-x86_64-rhel-7.2-a121103c922847ba5010819a3f250f1f7fc84ab8/tools/testing/selftests/bpf'

make: Entering directory '/usr/src/linux-selftests-x86_64-rhel-7.2-a121103c922847ba5010819a3f250f1f7fc84ab8/tools/testing/selftests/sysctl'
selftests: run_numerictests [PASS]
selftests: run_stringtests [PASS]
make: Leaving directory '/usr/src/linux-selftests-x86_64-rhel-7.2-a121103c922847ba5010819a3f250f1f7fc84ab8/tools/testing/selftests/sysctl'
EOF
      actual = `echo "#{stdout}" | #{stats_script}`.split("\n")
      expect(actual).to eq(['bpf.test_kmod.sh.fail: 1', 'sysctl.run_numerictests.pass: 1', 'sysctl.run_stringtests.pass: 1', 'total_test: 3'])
    end

    it 'stats compilation fail' do
      stdout = <<EOF
2017-01-30 23:57:13 make run_tests -C x86
make: Entering directory '/usr/src/linux-selftests-x86_64-rhel-7.2-a121103c922847ba5010819a3f250f1f7fc84ab8/tools/testing/selftests/x86'
gcc -m64 -o single_step_syscall_64 -O2 -g -std=gnu99 -pthread -Wall  single_step_syscall.c -lrt -ldl
gcc -m64 -o sysret_ss_attrs_64 -O2 -g -std=gnu99 -pthread -Wall  sysret_ss_attrs.c thunks.S -lrt -ldl
Makefile:47: recipe for target 'sysret_ss_attrs_64' failed
make: Leaving directory '/usr/src/linux-selftests-x86_64-rhel-7.2-a121103c922847ba5010819a3f250f1f7fc84ab8/tools/testing/selftests/x86'
EOF
      actual = `echo "#{stdout}" | #{stats_script}`.split("\n")
      expect(actual).to eq(['x86.make.fail: 1', 'total_test: 0'])
    end

    it 'stats mqueue result' do
      stdout = <<EOF
        Test #2b: Time send/recv message, queue full, increasing prio
:
                (100000 iterations)
                Filling queue...done.           0.23502215s
                Testing...done.
                Send msg:                       0.48443412s total time
                                                484 nsec/msg
                Recv msg:                       0.42612149s total time
                                                426 nsec/msg
                Draining queue...done.          0.17199103s

        Test #2c: Time send/recv message, queue full, decreasing prio
:
                (100000 iterations)
                Filling queue...done.           0.23586541s
                Testing...done.
                Send msg:                       0.49698382s total time
                                                496 nsec/msg
                Recv msg:                       0.42457983s total time
                                                424 nsec/msg
                Draining queue...done.          0.17599680s
EOF
      actual = `echo "#{stdout}" | #{stats_script}`.split("\n")
      expect(actual).to eq(["mqueue.nsec_per_msg: #{(484 + 426 + 496 + 424) / 4}", 'total_test: 1'])
    end
  end
end
