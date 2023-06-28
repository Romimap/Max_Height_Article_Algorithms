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
    cv::Mat* ans = new cv::Mat(data.size().width, data.size().height, CV_64FC3, cv::Scalar(0, 0, 0));
    for (int x = 0; x < data.size().width; x++) {
        for (int y = 0; y < data.size().height; y++) {
            cv::Point p(x, y);
            cv::Vec3b pdata = data.at<cv::Vec3b>(p);
            cv::Vec3d ddata(u8f64(pdata[0]), u8f64(pdata[1]), u8f64(pdata[2]));
            ans->at<cv::Vec3d>(p) = ddata;
        }    
    }

    return ans;
}

void save(std::string path, cv::Mat* data) {
    cv::Mat ans = cv::Mat(data->size().width, data->size().height, CV_8UC3, cv::Scalar(0, 0, 0));
    for (int x = 0; x < data->size().width; x++) {
        for (int y = 0; y < data->size().height; y++) {
            cv::Point p(x, y);
            cv::Vec3d ddata = data->at<cv::Vec3d>(p);
            cv::Vec3b pdata(f64u8(ddata[0]), f64u8(ddata[1]), f64u8(ddata[2]));
	        //printf("(%f, %f, %f) -> (%d, %d, %d)\n", ddata[0], ddata[1], ddata[2], pdata[0], pdata[1], pdata[2]);
            ans.at<cv::Vec3b>(p) = pdata; 
        }
    }
    cv::imwrite(path, ans);
}

void scale(cv::Mat* data, double s) {
    for (int x = 0; x < data->size().width; x++) {
        for (int y = 0; y < data->size().height; y++) {
            cv::Point p(x, y);
            data->at<cv::Vec3d>(p) = data->at<cv::Vec3d>(p) * s;
        }
    }
}

#endif