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
The arbiter logic is built as an independent module set between m entries producer and n entries consumer

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
To running examples of m_to_n communication\
In folder New470Dev, run `make sim_m_n_int`.