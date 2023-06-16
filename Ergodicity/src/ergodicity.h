#ifndef __ERGODICITY__
#define __ERGODICITY__

#include <vector>
#include <opencv2/opencv.hpp>

class Ergodicity {
private:
    std::vector<cv::Mat*>* m_t;
    std::vector<cv::Scalar>* m_t_mean;
    std::vector<std::vector<cv::Scalar>>* m_uv_mean;
    int m_w; //Width of a realisation
    int m_h; //Height of a realisation
    int m_d; //Depth, number of realisations


public:
    Ergodicity (std::vector<cv::Mat*>* t) m_t(t) {
        m_d = m_t->size();
        m_w = t->at(0).size().width;
        m_h = t->at(0).size().height;

        m_t_mean = new std::vector<cv::Scalar>()
        m_uv_mean = new std::vector<std::vector<cv::Scalar>>()

        //TODO: init tmean and uvmean
    }
};

#endif