#ifndef __HEX__
#define __HEX__

#include <opencv2/opencv.hpp>
#include "blend.h"
#include <math.h>


class Hex : public Blend {
public:
    cv::Vec3d Evaluate(cv::Point uv, float v1, float v2, cv::Point off1, cv::Point off2) override {
        cv::Point uv1 = uv + off1;
        cv::Point uv2 = uv + off2;

        uv1.x %= m_T1->size().width;
        uv1.y %= m_T1->size().height;
        uv2.x %= m_T1->size().width;
        uv2.y %= m_T1->size().height;

        cv::Scalar I1 = cv::Scalar(m_T1->at<cv::Vec3d>(uv1));
        cv::Scalar I2 = cv::Scalar(m_T2->at<cv::Vec3d>(uv2));

        double S1 = (I1[0]) * 0.114 + (I1[1]) * 0.587 + (I1[2]) * 0.299;
        double S2 = (I2[0]) * 0.114 + (I2[1]) * 0.587 + (I2[2]) * 0.299;

        double l = 5;

        double w1 = pow((S1*v1), l) / (pow((S1*v1), l) + pow((S2*v2), l));
        double w2 = pow((S2*v2), l) / (pow((S1*v1), l) + pow((S2*v2), l));

        return w1 * m_T1->at<cv::Vec3d>(uv1) + w2 * m_T2->at<cv::Vec3d>(uv2);
    }

public:
    Hex (cv::Mat* T1, cv::Mat* T2) : Blend(T1, T2) {

    }
};

#endif