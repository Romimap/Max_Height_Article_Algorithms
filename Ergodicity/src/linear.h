#ifndef __LINEAR__
#define __LINEAR__

#include <opencv2/opencv.hpp>
#include "blend.h"


class Linear : public Blend {
public:
    cv::Vec3b Evaluate(cv::Point uv, float v1, float v2, cv::Point off1, cv::Point off2) override {
        cv::Point uv1 = uv + off1;
        cv::Point uv2 = uv + off2;

        uv1.x %= m_T1->size().width;
        uv1.y %= m_T1->size().height;
        uv2.x %= m_T1->size().width;
        uv2.y %= m_T1->size().height;

        return v1 * m_T1->at<cv::Vec3b>(uv1) + v2 * m_T2->at<cv::Vec3b>(uv2);
    }

public:
    Linear (cv::Mat* T1, cv::Mat* T2) : Blend(T1, T2) {

    }
};

#endif