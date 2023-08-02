#ifndef __BLEND__
#define __BLEND__

#include <opencv2/opencv.hpp>
#include <omp.h>

class Blend {
protected:
    cv::Mat* m_T1;
    cv::Mat* m_T2;

    virtual cv::Vec3d Evaluate(cv::Point uv, float v1, float v2, cv::Point off1, cv::Point off2) = 0;

public:
    Blend(cv::Mat* T1, cv::Mat* T2) : m_T1(T1), m_T2(T2) {
        assert(m_T1->size().width == m_T2->size().width);
        assert(m_T1->size().height == m_T2->size().height);
        assert(m_T1->type() == m_T2->type());

    }

    cv::Mat* Process(cv::Point off1, cv::Point off2) {
        int w = m_T1->size().width / 4;
        int h = 1;
        cv::Mat* T = new cv::Mat(h, w, m_T1->type());
        
//        #pragma omp parallel for
        for(int x = 0; x < w; x++) {
            for(int y = 0; y < h; y++) {
                T->at<cv::Vec3d>(y, x) = Evaluate(cv::Point(x, y), (float)x / (float)(w - 1), 1.0f - (float)x / (float)(w - 1), off1, off2);
            }
        }

        return T;
    }
};

#endif