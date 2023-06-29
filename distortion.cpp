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
    Vdistortion* dut = new Vdistortion();
#ifdef SIM_TRACE
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("vdistortion.vcd");
#endif

    for (int channel = 0; channel < a.getNumChannels(); channel++)
    {
        int samples =a.getNumSamplesPerChannel();
        dut->clk = 0;
        dut->rst_n = 1;
        for (int i = 0; i < samples + PIPELINE; i++)
        { 
            if (i < samples){
                float sf = a.samples[channel][i];//from -1 to +1
                sf = sf * 32768;//from -32768 to +32767
                int16_t si = static_cast<int16_t>(sf);
                dut->IN = si;
            }
            if (i >= PIPELINE){
                int16_t si = dut->OUT;
                float sf = static_cast<float>(si);
                sf = sf / 32768;
                a.samples[channel][i-PIPELINE] = sf;
            }
            if (sim_time == 1){
                dut->rst_n = 0;
            }
            if (sim_time == 4){
                dut->rst_n = 1;
            }
            dut->clk = 1;
            dut->eval();
            #ifdef SIM_TRACE
                m_trace->dump(sim_time);
            #endif
            sim_time++;    
            dut->clk = 0;
            dut->eval();
            #ifdef SIM_TRACE
                m_trace->dump(sim_time);
            #endif
            sim_time++;
        }


    }
#ifdef SIM_TRACE
    m_trace->close();
#endif
    delete dut;
    a.save (outputFile);


    exit(EXIT_SUCCESS);
}