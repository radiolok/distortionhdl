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

void convert(const std::string& inputFilePath, const std::string& outputFilePath)
{
    AudioFile<float> a;
    bool loadedOK = a.load (inputFilePath);
    assert (loadedOK);
    
    //---------------------------------------------------------------
    // 3. Let's apply a gain to every audio sample
    
    float gain = 0.5f;

    for (int i = 0; i < a.getNumSamplesPerChannel(); i++)
    {
        for (int channel = 0; channel < a.getNumChannels(); channel++)
        {
            a.samples[channel][i] = a.samples[channel][i] * gain;
        }
    }
    
    a.save (outputFilePath);
}


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

    convert(inputFile, outputFile);

    Vdistortion *dut = new Vdistortion;
    Verilated::traceEverOn(true);
#ifdef SIM_TRACE
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("vdistortion.vcd");
#endif
    dut->clk = 0;
    dut->rst_n = 1;
    while (sim_time < 100) {
        dut->clk ^= 1;
        if (sim_time == 1){
            dut->rst_n = 0;
        }
        if (sim_time == 4){
            dut->rst_n = 1;
        }
        dut->eval();
    #ifdef SIM_TRACE
        if (sim_time < MAX_TRACE_TIME)
            m_trace->dump(sim_time);
    #endif
        sim_time++;
    }

#ifdef SIM_TRACE
    m_trace->close();
#endif
    delete dut;
    exit(EXIT_SUCCESS);
}