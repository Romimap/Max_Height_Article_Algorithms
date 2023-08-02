#ifndef __MAXPRIORITY__
#define __MAXPRIORITY__

#include <opencv2/opencv.hpp>
#include "blend.h"
#include <math.h>


class MaxPriority : public Blend {
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

        S2 = 1.0 - S2;

        double w1 = 0;
        if (S1 + v1 > S2 + v2) w1 = 1;
        double w2 = 1 - w1;

        return w1 * m_T1->at<cv::Vec3d>(uv1) + w2 * m_T2->at<cv::Vec3d>(uv2);
    }

public:
    MaxPriority (cv::Mat* T1, cv::Mat* T2) : Blend(T1, T2) {

    }
};

#endif