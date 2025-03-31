@@
@@
srcip = iph -> saddr;
+ int cpu = bpf_get_smp_processor_id()
+ int index = cpu % NUM_META
+ fast_forward_state(data, index, src_ip);