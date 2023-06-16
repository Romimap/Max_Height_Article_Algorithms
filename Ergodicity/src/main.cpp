#include "../includes/globals.h"
#include "linear.h"
#include <string>
#include <vector>

int main () {
	std::string T1_PATH = "textures/T1.png";
	std::string T2_PATH = "textures/T2.png";
	cv::Mat T1 = cv::imread(T1_PATH);
	cv::Mat T2 = cv::imread(T2_PATH);
	Linear linear(&T1, &T2);
	std::vector<cv::Mat*>* t = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		t->push_back(linear.Process(off1, off2));

		std::string T_PATH = "out/T_" + std::to_string(i) + ".png";
		cv::imwrite(T_PATH , *t->at(i));
	}

	



	return 0;
}
