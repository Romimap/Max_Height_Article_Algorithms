#ifndef __ERGODICITY__
#define __ERGODICITY__

#include <vector>
#include <opencv2/opencv.hpp>

class Ergodicity {
public:
    std::vector<cv::Mat*>* m_realisation;

    std::vector<cv::Scalar>* m_realisation_mean;
    std::vector<std::vector<cv::Scalar>*>* m_ray_mean;
    cv::Scalar m_mean;
    
    std::vector<std::vector<std::vector<cv::Scalar>*>*>* m_ray_realisation_dev;
    std::vector<std::vector<cv::Scalar>*>* m_ray_stdev;
    std::vector<cv::Scalar>* m_slice_stdev;
    cv::Scalar m_stdev;
    
    int m_w; //Width of a realisation
    int m_h; //Height of a realisation
    int m_d; //Depth, number of realisations

public:
    Ergodicity (std::vector<cv::Mat*>* realisation) : m_realisation(realisation) {
        m_w = m_realisation->at(0)->size().width;
        m_h = m_realisation->at(0)->size().height;
        m_d = m_realisation->size();

        m_realisation_mean = new std::vector<cv::Scalar>();
        for (int i = 0; i < m_d; i++) {
            m_realisation_mean->push_back(cv::Scalar(0, 0, 0));
        }

        m_ray_mean = new std::vector<std::vector<cv::Scalar>*>();
        for (int x = 0; x < m_w; x++) {
            m_ray_mean->push_back(new std::vector<cv::Scalar>);
            for (int y = 0; y < m_h; y++) {
                m_ray_mean->at(x)->push_back(cv::Scalar(0, 0, 0));
            }
        }

        m_mean = cv::Scalar(0, 0, 0);

        for (int x = 0; x < m_w; x++) {
            for (int y = 0; y < m_h; y++) {
                for (int t = 0; t < m_d; t++) {
                    cv::Scalar xyt(m_realisation->at(t)->at<cv::Vec3b>(cv::Point(x, y)));
                    m_realisation_mean->at(t) += xyt / (double)(m_w * m_h);
                    m_ray_mean->at(x)->at(y) += xyt / (double)(m_d);
                    m_mean += xyt / (double)(m_w * m_h * m_d);
                }
            }
        }

        m_ray_realisation_dev = new std::vector<std::vector<std::vector<cv::Scalar>*>*>();
        for (int x = 0; x < m_w; x++) {
            m_ray_realisation_dev->push_back(new std::vector<std::vector<cv::Scalar>*>());
            for (int y = 0; y < m_h; y++) {
                m_ray_realisation_dev->at(x)->push_back(new std::vector<cv::Scalar>());
                for (int t = 0; t < m_d; t++) {
                    m_ray_realisation_dev->at(x)->at(y)->push_back(cv::Scalar(0, 0, 0));
                }
            }
        }

        m_ray_stdev = new std::vector<std::vector<cv::Scalar>*>();
        for (int x = 0; x < m_w; x++) {
            m_ray_stdev->push_back(new std::vector<cv::Scalar>());
            for (int y = 0; y < m_h; y++) {
                m_ray_stdev->at(x)->push_back(cv::Scalar(0, 0, 0));
            }
        }

        m_slice_stdev = new std::vector<cv::Scalar>();
        for (int x = 0; x < m_w; x++) {
            m_slice_stdev->push_back(cv::Scalar(0, 0, 0));
        }

        m_stdev = cv::Scalar(0, 0, 0);

        for (int x = 0; x < m_w; x++) {
            for (int y = 0; y < m_h; y++) {
                for (int t = 0; t < m_d; t++) {
                    cv::Scalar diff = m_ray_mean->at(x)->at(y) - m_realisation_mean->at(t);
                    cv::Scalar absdiff = cv::Scalar(std::abs(diff[0]), std::abs(diff[1]), std::abs(diff[2]));
                    m_ray_realisation_dev->at(x)->at(y)->at(t) = diff;
                    m_ray_stdev->at(x)->at(y) += absdiff / (double)(m_d);
                    m_slice_stdev->at(x) += absdiff / (double)(m_d * m_h);
                    m_stdev += absdiff / (double)(m_w * m_h * m_d);
                }
            }
        }


        cv::Mat out(m_w, m_h, m_realisation->at(0)->type(), cv::Scalar(0, 0, 0));
        for (int x = 0; x < m_w; x++) {
            for (int y = 0; y < m_h; y++) {
                cv::Scalar stdev_xy = m_ray_stdev->at(x)->at(y) * 10;

                stdev_xy[0] = std::clamp(stdev_xy[0], 0.0, 255.0);
                stdev_xy[1] = std::clamp(stdev_xy[1], 0.0, 255.0);
                stdev_xy[2] = std::clamp(stdev_xy[2], 0.0, 255.0);

                out.at<cv::Vec3b>(cv::Point(x, y)) = cv::Vec3b(stdev_xy[0], stdev_xy[1], stdev_xy[2]);
            }
        }

        cv::imwrite("stdev_hex.png", out);

    }
};

#endif