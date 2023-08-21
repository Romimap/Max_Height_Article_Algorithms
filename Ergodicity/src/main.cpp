#include <opencv2/opencv.hpp>
#include <string>
#include <vector>
#include "hex.h"
#include "maxpriority.h"
#include "linear.h"
#include "variancepreserving.h"
#include "processmetrics.h"
#include "../includes/globals.h"
#include "utils.h"
#include <iostream>
#include <fstream>


void printVec3 (cv::Vec3d s) {
	printf("(%f, %f, %f)\n", s[0], s[1], s[2]);
}

cv::Mat *T1 = nullptr;
cv::Mat *T2 = nullptr;

void runLinear () {
	Linear method(T1, T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if ((i + 1)%1024 == 1) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(method.Process(off1, off2));
	}

	ProcessMetrics processMetrics(realisation);
	
	cv::Mat h(256, processMetrics.m_w, CV_64FC3);

	for (int u = 0; u < processMetrics.m_w; u++) {
		int* distribution = processMetrics.GetRayDistribution(0, u);
		int sizes[] = {256};
		for (int n = 0; n < 256; n++) {
			int b = distribution[processMetrics.At(n, 0, sizes)];
			int g = distribution[processMetrics.At(n, 1, sizes)];
			int r = distribution[processMetrics.At(n, 2, sizes)];

			h.at<cv::Vec3d>(n, u) = cv::Vec3d(b, g, r);
		}
	}

	scale(&h, 1.0/((double)T_TIERATIONS / 32.0));

	save("lin.png", &h);
}

void runHex () {
	Hex method(T1, T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if ((i + 1)%1024 == 1) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(method.Process(off1, off2));
	}

	ProcessMetrics processMetrics(realisation);
	
	cv::Mat h(256, processMetrics.m_w, CV_64FC3);

	for (int u = 0; u < processMetrics.m_w; u++) {
		int* distribution = processMetrics.GetRayDistribution(0, u);
		int sizes[] = {256};
		for (int n = 0; n < 256; n++) {
			int b = distribution[processMetrics.At(n, 0, sizes)];
			int g = distribution[processMetrics.At(n, 1, sizes)];
			int r = distribution[processMetrics.At(n, 2, sizes)];

			h.at<cv::Vec3d>(n, u) = cv::Vec3d(b, g, r);
		}
	}

	scale(&h, 1.0/((double)T_TIERATIONS / 32.0));

	save("hex.png", &h);
}

void runBlend () {
	printf("undefined\n");
}

void runVariancePreserving () {
	VariancePreserving method(T1, T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if ((i + 1)%1024 == 1) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(method.Process(off1, off2));
	}

	ProcessMetrics processMetrics(realisation);
	
	cv::Mat h(256, processMetrics.m_w, CV_64FC3);

	for (int u = 0; u < processMetrics.m_w; u++) {
		int* distribution = processMetrics.GetRayDistribution(0, u);
		int sizes[] = {256};
		for (int n = 0; n < 256; n++) {
			int b = distribution[processMetrics.At(n, 0, sizes)];
			int g = distribution[processMetrics.At(n, 1, sizes)];
			int r = distribution[processMetrics.At(n, 2, sizes)];

			h.at<cv::Vec3d>(n, u) = cv::Vec3d(b, g, r);
		}
	}

	scale(&h, 1.0/((double)T_TIERATIONS / 32.0));

	save("variance_preserving.png", &h);
}

void runMax () {
	MaxPriority method(T1, T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if ((i + 1)%1024 == 1) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(method.Process(off1, off2));
	}

	ProcessMetrics processMetrics(realisation);
	
	cv::Mat h(256, processMetrics.m_w, CV_64FC3);

	int max = 0;
	for (int u = 0; u < processMetrics.m_w; u++) {
		int* distribution = processMetrics.GetRayDistribution(0, u);
		int sizes[] = {256};
		for (int n = 0; n < 256; n++) {
			int b = distribution[processMetrics.At(n, 0, sizes)];
			int g = distribution[processMetrics.At(n, 1, sizes)];
			int r = distribution[processMetrics.At(n, 2, sizes)];

			if (max < b) max = b;
			if (max < g) max = g;
			if (max < r) max = r;

			h.at<cv::Vec3d>(n, u) = cv::Vec3d(b, g, r);
		}
	}

	scale(&h, 1.0/((double)T_TIERATIONS / 32.0));

	save("max_symetrized.png", &h);
}

int main () {
	T1 = load("T1.png");
	T2 = load("T2.png");

	runVariancePreserving();
	runLinear();
	runHex();
	runBlend();
	runMax();
	return 0;
}
