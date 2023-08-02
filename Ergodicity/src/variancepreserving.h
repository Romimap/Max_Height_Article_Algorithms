#ifndef __VARIANCEPRESERVING__
#define __VARIANCEPRESERVING__

#include <opencv2/opencv.hpp>
#include "blend.h"
#include <math.h>

//TODO : Strange behaviour with the sqrt, histogram transformation
class VariancePreserving : public Blend {
private:
    cv::Vec3d m_mean;
public:
    cv::Vec3d Evaluate(cv::Point uv, float v1, float v2, cv::Point off1, cv::Point off2) override {
        cv::Point uv1 = uv + off1;
        cv::Point uv2 = uv + off2;

        uv1.x %= m_T1->size().width;
        uv1.y %= m_T1->size().height;
        uv2.x %= m_T1->size().width;
        uv2.y %= m_T1->size().height;


        cv::Vec3d t1 = m_T1->at<cv::Vec3d>(uv1) - m_mean;
        cv::Vec3d t2 = m_T2->at<cv::Vec3d>(uv2) - m_mean;


        double s = sqrt(pow(v1, 2) + pow(v2, 2)) + 0.2;
        cv::Vec3d t = (v1 * t1 + v2 * t2) / s + m_mean;
        
        return t;
    }

public:
    VariancePreserving (cv::Mat* T1, cv::Mat* T2) : Blend(T1, T2) {
        m_mean = cv::Vec3d(0, 0, 0);
        for(int x = 0; x < T1->size().width; x++) {
            for (int y = 0; y < T1->size().height; y++) {
                m_mean = m_mean + T1->at<cv::Vec3d>(y, x);
            }
        }
        m_mean = m_mean / (double)(T1->size().width * T1->size().height);
    }
};

#endif