#ifndef __VARIANCEPRESERVING__
#define __VARIANCEPRESERVING__

#include <opencv2/opencv.hpp>
#include "blend.h"
#include <math.h>
#include <vector>
#include "utils.h"

//TODO : Strange behaviour with the sqrt, histogram transformation
class VariancePreserving : public Blend {
private:
    const double GAUSSIAN_AVERAGE = 0.5;
    const double GAUSSIAN_STD = 0.16667;
    cv::Mat* m_gaussianT1;
    cv::Mat* m_gaussianT2;
    struct Entry {
        float v;
        float G;
        int x;
        int y;
    };
    std::vector<Entry> lut1[3] = {std::vector<Entry>(), std::vector<Entry>(), std::vector<Entry>()};
    std::vector<Entry> lut2[3] = {std::vector<Entry>(), std::vector<Entry>(), std::vector<Entry>()};

private:
    double CDF (double x, double mu, double sigma) {
        double U = 0.5 * (1.0 + erf((x - mu) / (sigma * sqrt(2.0))));
        return U;
    }

    double invCDF (double U, double mu, double sigma) {
        double ans = 0;

        double off = 0.5;
        for (int i = 0; i < 10; i++) {
            if (CDF(ans, GAUSSIAN_AVERAGE, GAUSSIAN_STD) < U) {
                ans += off;
            } else {
                ans -= off;
            }
            off /= 2.0;
        }

        return ans;
    }



    cv::Mat* ComputeHistogramTransformation(cv::Mat* T, std::vector<Entry> lut[]) {
        for (int y = 0; y < T->size().height; y++) {
            for (int x = 0; x < T->size().width; x++) {
                for (int c = 0; c < 3; c++) {
                    Entry entry;
                    entry.v = T->at<cv::Vec3d>(y, x)[c];
                    entry.G = 0;
                    entry.x = x;
                    entry.y = y;
                    lut[c].push_back(entry);
                }
            }
        }

        for (int c = 0; c < 3; c++) {
            sort(lut[c].begin(), lut[c].end(), 
                [](Entry a, Entry b) {
                    return a.v < b.v;
                }
            );
        }

        cv::Mat* out = new cv::Mat(T->size().height, T->size().width, T->type());

        for (int i = 0; i < lut[0].size(); i++) {
            double U = ((double)i + 0.5) / (lut[0].size());
            double G = invCDF(U, GAUSSIAN_AVERAGE, GAUSSIAN_STD);
            for (int c = 0; c < 3; c++) {
                lut[c][i].G = G;
                cv::Vec3d texel = out->at<cv::Vec3d>(lut[c][i].y, lut[c][i].x);
                texel[c] = lut[c][i].G;
                out->at<cv::Vec3d>(lut[c][i].y, lut[c][i].x) = texel;
            }
        }

        return out;
    }

    cv::Vec3d inverseTransform(cv::Vec3d G, std::vector<Entry> lut[]) {
        cv::Vec3d U;
        cv::Vec3d ans;
        for (int c = 0; c < 3; c++) {
            U[c] = CDF(G[c], GAUSSIAN_AVERAGE, GAUSSIAN_STD);
            int i = U[c] * lut[c].size();
            if (i < 0) i = 0;
            if (i > lut[c].size() - 1) i = lut[c].size() - 1;
            ans[c] = lut[c][i].v;
        }
        return ans;
    }

    cv::Mat* inverseTransform(cv::Mat *T, std::vector<Entry> lut[]) {
        cv::Mat* out = new cv::Mat(T->size().height, T->size().width, T->type());

        for (int x = 0; x < T->size().width; x++) {
            for (int y = 0; y < T->size().height; y++) {
                cv::Vec3d G = T->at<cv::Vec3d>(y, x);
                cv::Vec3d D = inverseTransform(G, lut);
                out->at<cv::Vec3d>(y, x) = D;
            }
        }

        return out;
    }

public:
    cv::Vec3d Evaluate(cv::Point uv, float v1, float v2, cv::Point off1, cv::Point off2) override {
        cv::Point uv1 = uv + off1;
        cv::Point uv2 = uv + off2;

        uv1.x %= m_T1->size().width;
        uv1.y %= m_T1->size().height;
        uv2.x %= m_T1->size().width;
        uv2.y %= m_T1->size().height;


        cv::Vec3d t1 = m_gaussianT1->at<cv::Vec3d>(uv1);
        cv::Vec3d t2 = m_gaussianT2->at<cv::Vec3d>(uv2);
        cv::Vec3d e =  cv::Vec3d(GAUSSIAN_AVERAGE, GAUSSIAN_AVERAGE, GAUSSIAN_AVERAGE);

        cv::Vec3d t = ((v1 * t1 + v2 * t2 - e) / sqrt(v1*v1 + v2*v2)) + e;
        
        return inverseTransform(t, lut1);
    }

    VariancePreserving (cv::Mat* T1, cv::Mat* T2) : Blend(T1, T2) {
        save("m_T1.png", m_T1);

        m_gaussianT1 = ComputeHistogramTransformation(T1, lut1);
        m_gaussianT2 = ComputeHistogramTransformation(T2, lut2);
    }
};

#endif