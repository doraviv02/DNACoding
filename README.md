
Data Storage Error Correction Accelerator for DNA Memory

Project Overview

This project explores DNA memory as a revolutionary method for archival data storage, focusing on its potential for high durability and density. Despite these advantages, DNA memory suffers from high error rates and slow read/write speeds, necessitating advanced error correction techniques.

Our work involves implementing a probabilistic error correction algorithm based on the Varshamov-Tenengolts (VT) coding system and validating it through both software simulations and hardware acceleration.

Key Features

	1.	Error Model:
	•	DNA memory errors are modeled as Insertion, Deletion, or Substitution (IDS) of nucleotides.
	•	Exploits statistical dependencies between strands for improved error correction accuracy.
	2.	Algorithm Steps:
	•	Encoding: Transform input strands into VT codes.
	•	Transmission: Simulate IDS errors.
	•	Transition Probabilities: Compute using forward/backward passes.
	•	Probability Calculation: Aggregate strand probabilities for decoding.
	•	Decoding: Sum probabilities to determine bit values.
	3.	System Architecture:
	•	Software Implementation (Python):
	•	VT Encoder
	•	IDS Error Generator
	•	Soft/Hard Decoders
	•	Probability Calculations
	•	Hardware Implementation (SystemVerilog):
	•	Multi-strand memory for parallel processing
	•	Processing Unit Controller
	•	VT Decoder

Results

	1.	Software Simulation:
	•	Recreated the paper’s error correction trends.
	•	Differences attributed to randomness and unspecified BER calculation methods.
	2.	Hardware Accelerator:
	•	Achieved a Proof of Concept (POC) hardware design.
	•	Synthesized a SISO decoder module with promising performance in timing, power, and area metrics.

Challenges & Conclusions

	•	Challenges:
	•	Missing/misleading details in the reference paper.
	•	Computational limitations in simulations.
	•	Divergent requirements for software vs. hardware implementations.
	•	Conclusions:
	•	Successfully recreated the original model and outcomes.
	•	Delivered a viable hardware accelerator for DNA memory error correction.
	•	Established a framework for further development and optimization.

Future Work

	•	Optimize hardware design for scalability and efficiency.
	•	Explore alternative error models and coding schemes.
	•	Enhance software simulations for broader parameter testing.

References

	•	Springer Chapter
	•	BBC Bitesize
	•	Semantics Scholar Paper
