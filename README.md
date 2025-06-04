# New470Dev
This is a folder about formal module communication protocol between producer and consumer


## ./basejump_stl:
Easy examples showing four basic ways one producer can communicate with a consumer
| producer\consumer | volunteering | demanding |
|---------------|----------|----------|
| volunteering  | rv->&  | v->r  |
| demanding     | r->v  | FIFO |

Volunteering: Modules tell other modules whether they have something valid to send (producer) or they are ready to receive data (consumer) 

Demanding: Modules wait for the signals from others (valid or ready) and then decide whether they want to respond to it
## ./m_n_communication: 
Latest update, it contains example about how a m entries producer communicate with a n entries consumer using interface array

#### m_n_arbiter.sv
The arbiter logic is built as an independent module set between m entries producer and n entries consumer. \
\
Parameter `BANDWIDTH = 2` is set to indicate that this arbiter can allow maximum 2 package sent from producer to consumer. \
\
Priority selector (verilog/psel_gen.sv) and one hot translater (verilog/one_hot_translater.sv) are used. 

#### consumer_multi_vo.sv
The volunteering consumer will tell the outside (m_n_arbiter) which entries are ready to receive data. Communication channel is built in a form of interface (inf_temp) 

#### producer_multi_vo.sv
The volunteering producer will tell the outside (m_n_arbiter) which entries are sending valid data. Communication channel is built in a form of interface (inf_temp) 

#### inf_temp.svh
Interface inf_temp is built to make communication between modules more formal. It is defined to be
<pre>interface inf_temp;
    logic        valid;
    logic        ready;
    logic [7:0]  payload;
    logic [7:0]  addr;
endinterface
</pre>
for flexible expansion to multiple entries communication

#### monitor.sv
Monitor is built as an independent module to better inspect channel communication and conveniently change monitoring code

# Running Example
### m to n communication
To running examples of m_to_n communication \
In folder New470Dev, run `make sim_m_n_int`. \
\
All 16 entries of the producer are trying to transfer data to a consumer with 8 entries \
\
Clock 0:
| producer empty bits | 0000 | 0000 | 0000 | 0000 |
|---------------|----------|----------|----------|----------|
| consumer empty bits | 11 | 11 | 11 | 11 |

\
Clock 1:
| producer empty bits | 1000 | 0000 | 0000 | 0001 |
|---------------|----------|----------|----------|----------|
| consumer empty bits | 01 | 11 | 11 | 10 |

1st and 16th entry are selected by arbiter and transferred to consumer's 1st and 8th entry

\
Clock 2:
| producer empty bits | 1100 | 0000 | 0000 | 0011 |
|---------------|----------|----------|----------|----------|
| consumer empty bits | 00 | 11 | 11 | 00 |

2nd and 15th entry are selected by arbiter and transferred to consumer's 2nd and 7th entry

...

Clock 4:
| producer empty bits | 1111 | 0000 | 0000 | 1111 |
|---------------|----------|----------|----------|----------|
| consumer empty bits | 00 | 00 | 00 | 00 |

4th and 13th entry are selected by arbiter and transferred to consumer's 4th and 5th entry. Consumer now is all occupied and producer will not be able to transfer more data to consumer

\
Clock 5:
| producer empty bits | 1111 | 0000 | 0000 | 1111 |
|---------------|----------|----------|----------|----------|
| consumer empty bits | 00 | 00 | 00 | 00 |

# Syntax Example
An example of defining and instantiating interfaces with parameters and self-defined datatype.

    