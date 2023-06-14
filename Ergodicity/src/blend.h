#ifndef __BLEND__
#define __BLEND__

#include <opencv2/opencv.hpp>
#include <omp.h>

class Blend {
protected:
    cv::Mat* m_T1;
    cv::Mat* m_T2;
    cv::Mat* m_T;

    virtual cv::Vec3b Evaluate(int x, int y, float v1, float v2) = 0;

public:
    Blend(cv::Mat* T1, cv::Mat* T2) : m_T1(T1), m_T2(T2) {
        assert(m_T1->size().width == m_T1->size().width);
        assert(m_T1->size().height == m_T1->size().height);
        assert(m_T1->type() == m_T1->type());

        m_T = new cv::Mat(m_T1->size().width, m_T1->size().height, m_T1->type(), cv::Scalar(0, 0, 0));
    }

    void Process() {
        int w = m_T1->size().width;
        int h = m_T1->size().height;

        #pragma omp parallel for
        for(int x = 0; x < w; x++) {
            for(int y = 0; y < h; y++) {
                m_T->at<cv::Vec3b>(cv::Point(x, y)) = Evaluate(x, y, (float)x / (float)(w - 1), 1.0f - (float)x / (float)(w - 1));
            }
        }
    }

    cv::Mat* getT() {
        return m_T;
    }
};

#endif