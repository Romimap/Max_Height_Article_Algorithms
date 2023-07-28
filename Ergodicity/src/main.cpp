#include <opencv2/opencv.hpp>
#include <string>
#include <vector>
#include "hex.h"
#include "linear.h"
#include "processmetrics.h"
#include "../includes/globals.h"
#include "utils.h"
#include <iostream>
#include <fstream>


void printVec3 (cv::Vec3d s) {
	printf("(%f, %f, %f)\n", s[0], s[1], s[2]);
}

using Method = Linear;


int main () {
	std::string T1_PATH = "textures/T1.png";
	std::string T2_PATH = "textures/T2.png";
	cv::Mat *T1 = load(T1_PATH);
	cv::Mat *T2 = load(T2_PATH);
	Method method(T1, T2);
	std::vector<cv::Mat*>* realisation = new std::vector<cv::Mat*>();

	for (int i = 0; i < T_TIERATIONS; i++) {
		if (i%32 == 0) printf("%d\n", i);
		cv::Point off1(rand(), rand());
		cv::Point off2(rand(), rand());

		realisation->push_back(method.Process(off1, off2));

		if (i < 32) {
			std::string T_PATH = "out/T_" + std::to_string(i) + ".png";
			save(T_PATH, realisation->at(i));
		}
	}

	ProcessMetrics processMetrics(realisation);
	
	cv::Mat rayMean(processMetrics.m_h, processMetrics.m_w, CV_64FC3, cv::Scalar(0, 0, 0));

	for (int u = 0; u < processMetrics.m_w; u++) {
		for (int v = 0; v < processMetrics.m_h; v++) {
			rayMean.at<cv::Vec3d>(v, u) = processMetrics.GetRayMean(v, u);
		}
	}

	save("rayMean.png", &rayMean);
	scale(&rayMean, 10);
	save("rayMean10.png", &rayMean);
	scale(&rayMean, 10);
	save("rayMean100.png", &rayMean);


	cv::Mat rayVar(processMetrics.m_h, processMetrics.m_w, CV_64FC3, cv::Scalar(0, 0, 0));

	for (int u = 0; u < processMetrics.m_w; u++) {
		for (int v = 0; v < processMetrics.m_h; v++) {
			rayVar.at<cv::Vec3d>(v, u) = processMetrics.GetRayVariance(v, u);
		}
	}

	save("rayVar.png", &rayVar);
	scale(&rayVar, 10);
	save("rayVar10.png", &rayVar);
	scale(&rayVar, 10);
	save("rayVar100.png", &rayVar);

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

	scale(&h, 1.0/double(max));

	save("h.png", &h);
}
