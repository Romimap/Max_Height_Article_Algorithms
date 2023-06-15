#ifndef __LINEAR__
#define __LINEAR__

#include "blend.h"

class VariancePreserving : public Blend {
public:
    cv::Vec3b Evaluate(int x, int y, float v1, float v2) override {
        return v1 * m_T1->at<cv::Vec3b>(x, y) + v2 * m_T2->at<cv::Vec3b>(x, y);
    }

public:
    VariancePreserving (cv::Mat* T1, cv::Mat* T2) : Blend(T1, T2) {

    }
};

#endif