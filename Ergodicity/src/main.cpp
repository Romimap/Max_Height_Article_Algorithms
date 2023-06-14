#include "../includes/globals.h"
#include "linear.h"

int main () {
	cv::String T1_PATH("textures/T1.png");
	cv::String T2_PATH("textures/T2.png");
	cv::String T_PATH("textures/T.png");
	cv::Mat T1 = cv::imread(T1_PATH);
	cv::Mat T2 = cv::imread(T2_PATH);
	Linear linear(&T1, &T2);
	for (int i = 0; i < 100; i++) {
		printf("%d\n", i);
		linear.Process();
	}
	cv::Mat* T = linear.getT();

	cv::imwrite(T_PATH, *T);

	return 0;
}
