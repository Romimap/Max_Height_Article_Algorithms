#include <opencv2/opencv.hpp>
#include <string>
#include <vector>
#include "hex.h"
#include "ergodicity.h"
#include "../includes/globals.h"

void printScalar (cv::Scalar s) {
	printf("(%f, %f, %f)\n", s[0], s[1], s[2]);
}



int main () {
	std::string T1_PATH = "textures/T1.png";
	std::string T2_PATH = "textures/T2.png";
	cv::Mat T1 = cv::imread(T1_PATH);
	cv::Mat T2 = cv::imread(T2_PATH);
	Hex hex(&T1, &T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if (i%100 == 0) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(hex.Process(off1, off2));

		//std::string T_PATH = "out/T_" + std::to_string(i) + ".png";
		//cv::imwrite(T_PATH , *realisation->at(i));
	}

	Ergodicity ergodicity(realisation);

	printScalar(ergodicity.m_mean);
	printScalar(ergodicity.m_stdev);

	return 0;
}
