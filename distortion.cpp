#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <ctype.h>
#include <cmath>
#include <AudioFile.h>
#include <verilated.h>
#include "verilated_vpi.h"
#include <verilated_vcd_c.h>
#include "Vdistortion.h"


#define MAX_TRACE_TIME 60000000
vluint64_t sim_time = 0;

#define PIPELINE 2

typedef union {
  float f;
  uint32_t i;
} float_cast;

int main(int argc, char** argv, char** env) {
    int c = 0;
	std::string inputFile;
    std::string outputFile;
	while((c = getopt(argc, argv, "i:o:")) != -1){
		switch(c)
		{
		case 'h':
            std::cout << "distortion -i input.wav -o output.wav" << std::endl;
            std::cout << "use -h to show this menu" << std::endl;
            return 0;
			break;
		case 'i':
			inputFile = optarg;
			break;
		case 'o':
			outputFile = optarg;
			break;
		}
	}
    if (inputFile.empty() | outputFile.empty())
        return 0;

    AudioFile<float> a;
    bool loadedOK = a.load (inputFile);
    assert (loadedOK);

    Verilated::traceEverOn(true);
#ifdef SIM_TRACE
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    m_trace->open("vdistortion.vcd");
#endif
   

    float_cast val;

    for (int channel = 0; channel < a.getNumChannels(); channel++)
    {

        int samples =a.getNumSamplesPerChannel();
        int s1 = 0;
        int s2 = 0;

        Vdistortion* dut = new Vdistortion();
    #ifdef SIM_TRACE
        dut->trace(m_trace, 5);
    #endif
        dut->clk = 0;
        dut->rst_n = 1;
        for (int i = 0; i < samples + PIPELINE; i++)
        { 
            if (i < samples){
                val.f = a.samples[channel][i]; 
                s1++;
            }
            dut->IN = val.i;
            if (sim_time == 1){
                dut->rst_n = 0;
            }
            if (sim_time == 4){
                dut->rst_n = 1;
            }
            dut->clk ^= 1;
            dut->eval();
            #ifdef SIM_TRACE
                if (sim_time < MAX_TRACE_TIME)
                    m_trace->dump(sim_time);
            #endif
            sim_time++;
            if (i >= PIPELINE){
                val.i = dut->OUT;
                a.samples[channel][i-PIPELINE] = val.f;
                s2++;
            }

        }
        if (s1 == s2)
            std::cout << "OK!\n";
        delete dut;
    }

    a.save (outputFile);

#ifdef SIM_TRACE
    m_trace->close();
#endif
    exit(EXIT_SUCCESS);
}