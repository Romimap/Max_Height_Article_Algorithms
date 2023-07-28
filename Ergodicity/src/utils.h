#ifndef __UTILS__
#define __UTILS__

#include <opencv2/opencv.hpp>
#include <string>

double u8f64 (uchar c) {
    return (double)(c) / 255.0;
}

char f64u8 (double d) {
    return (char)std::min(255, std::max(0, (int)(d * 255.0)));
}

cv::Mat* load(std::string path) {
    cv::Mat data = cv::imread(path);
    cv::Mat* ans = new cv::Mat(data.size().height, data.size().width, CV_64FC3);
    for (int x = 0; x < ans->size().width; x++) {
        for (int y = 0; y < ans->size().height; y++) {
            cv::Vec3b pdata = data.at<cv::Vec3b>(y, x);
            ans->at<cv::Vec3d>(y, x) = cv::Vec3d(u8f64(pdata[0]), u8f64(pdata[1]), u8f64(pdata[2]));
        }    
    }

    return ans;
}

void save(std::string path, cv::Mat* data) {
    cv::Mat *ans = new cv::Mat(data->size().height, data->size().width, CV_64FC3);
    for (int x = 0; x < ans->size().width; x++) {
        for (int y = 0; y < ans->size().height; y++) {
            ans->at<cv::Vec3d>(y, x) = data->at<cv::Vec3d>(y, x) * 255.0;
        }
    }
    cv::imwrite(path, *ans);
}

void scale(cv::Mat* data, double s) {
    for (int x = 0; x < data->size().width; x++) {
        for (int y = 0; y < data->size().height; y++) {
            data->at<cv::Vec3d>(y, x) = data->at<cv::Vec3d>(y, x) * s;
        }
    }
}

#endif