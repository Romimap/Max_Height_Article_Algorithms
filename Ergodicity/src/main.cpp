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

#ifndef METHOD
 #define METHOD Linear
#endif

#ifndef OUTPATH
 #define OUTPATH "Sand_h_lin.png"
#endif

using Method = METHOD;
const char* outpath = OUTPATH;

int main () {
	std::string T1_PATH = "textures/T1.png";
	std::string T2_PATH = "textures/T2.png";
	cv::Mat *T1 = load(T1_PATH);
	cv::Mat *T2 = load(T2_PATH);
	Method method(T1, T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if ((i + 1)%1024 == 1) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(method.Process(off1, off2));

		if (i < 32) {
			std::string T_PATH = "out/T_" + std::to_string(i) + ".png";
			save(T_PATH, realisation->at(i));
		}
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

			h.at<cv::Vec3d>(255 - n, u) = cv::Vec3d(b, g, r);
		}
	}

	max = T_TIERATIONS / 32;

	scale(&h, 1.0/double(max));

	save(outpath, &h);
}
