#ifndef __PROCESSMETRICS__
#define __PROCESSMETRICS__

#include <opencv2/opencv.hpp>
#include <vector>
#include <omp.h>
#include <math.h>

class ProcessMetrics {
public: 
    cv::Vec3d* m_realisation;

    int m_w;
    int m_h;
    int m_l;

public:
    ProcessMetrics (std::vector<cv::Mat*>* realisations) {
        printf("Generating data structure ...\n");
        m_w = realisations->at(0)->size().width;
        m_h = realisations->at(0)->size().height;
        m_l = realisations->size();
        
        //Allocation
        m_realisation = (cv::Vec3d*)calloc(m_w * m_h * m_l, sizeof(cv::Vec3d));

        //Init
        int sizes[] = {m_w, m_h};
        #pragma omp parallel for
        for (int u = 0; u < m_w; u++) {
            for (int v = 0; v < m_h; v++) {
                for (int t = 0; t < m_l; t++) {
                    m_realisation[At(u, v, t, sizes)] = realisations->at(t)->at<cv::Vec3d>(u, v);
                }
            }
        }

        printf("Precomputing rays distribution ...\n");
        PrecomputeRayDistributions();
        printf("Precomputing realisations distribution ...\n");
        PrecomputeRealisationDistribution();
        printf("Precomputing rays mean ...\n");
        PrecomputeRayMean();
        printf("Precomputing realisations mean ...\n");
        PrecomputeRealisationMean();
        printf("Precomputing rays variance ...\n");
        PrecomputeRayVariance();
        printf("Precomputing realisations variance ...\n");
        PrecomputeRealisationVariance();
        
        printf("Done !\n");
    }

public:
    int At(int x) {
        return x;
    }

    int At(int x, int y, int* sizes) {
        return 
          x 
        + y * sizes[0];
    }

    int At(int x, int y, int z, int* sizes) {
        return 
          x 
        + y * sizes[0] 
        + z * sizes[0] * sizes[1];
    }

    int At(int x, int y, int z, int w, int* sizes) {
        return 
          x 
        + y * sizes[0] 
        + z * sizes[0] * sizes[1]
        + w * sizes[0] * sizes[1] * sizes[2];
    }
    

    // **** REALISATIONS
    // ** DISTRIBUTIONS

    int** m_precomputedRealisationDistribution = nullptr;
    void PrecomputeRealisationDistribution() {
        m_precomputedRealisationDistribution = (int**)calloc(m_l, sizeof(int*));

        #pragma omp parallel for
        for (int t = 0; t < m_l; t++) {
            m_precomputedRealisationDistribution[t] = GetRealisationDistribution(t, 0, 0, m_w, m_h);
        }
    }

    int* GetRealisationDistribution(int t, int u1, int v1, int u2, int v2) {
        int* distribution = (int*)calloc(256 * 3, sizeof(int));
        int rsizes[] = {m_w, m_h};
        int dsizes[] = {256};

        for (int u = u1; u < u2; u++) {
            for (int v = v1; v < v2; v++) {
                int b = (int)(m_realisation[At(u, v, t, rsizes)][0] * 255);
                int g = (int)(m_realisation[At(u, v, t, rsizes)][1] * 255);
                int r = (int)(m_realisation[At(u, v, t, rsizes)][2] * 255);

                distribution[At(b, 0, dsizes)] += 1;
                distribution[At(g, 0, dsizes)] += 1;
                distribution[At(r, 0, dsizes)] += 1;
            }
        }
        
        return distribution;
    }

    int* GetRealisationDistribution(int t) {
        return m_precomputedRealisationDistribution[At(t)];
    }

    // ** MEAN

    cv::Vec3d* m_precomputedRealisationMean;
    void PrecomputeRealisationMean () {
        m_precomputedRealisationMean = (cv::Vec3d*)calloc(m_l, sizeof(cv::Vec3d));

        #pragma omp parallel for
        for (int t = 0; t < m_l; t++) {
            m_precomputedRealisationMean[At(t)] = GetRealisationMean(t, 0, 0, m_w, m_h);
        }
    }

    cv::Vec3d GetRealisationMean(int t, int u1, int v1, int u2, int v2) {
        cv::Vec3d mean(0, 0, 0);
        int sizes[] = {m_w, m_h};

        for (int u = u1; u < u2; u++) {
            for (int v = v1; v < v2; v++) {
                mean += m_realisation[At(u, v, t, sizes)];
            }
        }

        mean /= (double)((u2 - u1) * (v2 - v1));
        return mean;
    }

    cv::Vec3d GetRealisationMean(int t) {
        return m_precomputedRealisationMean[At(t)];
    }

    // ** VARIANCE
    
    cv::Vec3d* m_precomputedRealisationVariance;
    void PrecomputeRealisationVariance () {
        m_precomputedRealisationVariance = (cv::Vec3d*)calloc(m_l, sizeof(cv::Vec3d));

        #pragma omp parallel for
        for (int t = 0; t < m_l; t++) {
            m_precomputedRealisationVariance[At(t)] = GetRealisationVariance(t, 0, 0, m_w, m_h);
        }
    }

    cv::Vec3d GetRealisationVariance(int t, int u1, int v1, int u2, int v2) {
        cv::Vec3d variance(0, 0, 0);
        int sizes[] = {m_w, m_h};

        cv::Vec3d meanuv1uv2 = GetRealisationMean(t, u1, v1, u2, v2);

        for (int u = u1; u < u2; u++) {
            for (int v = v1; v < v2; v++) {
                cv::Vec3d diff = meanuv1uv2 - m_realisation[At(u, v, t, sizes)];
                diff[0] = diff[0] * diff[0];
                diff[1] = diff[1] * diff[1];
                diff[2] = diff[2] * diff[2];
                variance += diff;
            }
        }

        variance /= (double)((u2 - u1) * (v2 - v1));
        return variance;
    }

    cv::Vec3d GetRealisationVariance(int t) {
        return m_precomputedRealisationVariance[At(t)];
    }

    // **** RAYS
    // ** DISTRIBUTIONS

    int** m_precomputedRayDistributions = nullptr;
    void PrecomputeRayDistributions() {
        m_precomputedRayDistributions = (int**)calloc(m_w * m_h, sizeof(int*));
        int sizes[] = {m_w};

        #pragma omp parallel for
        for (int u = 0; u < m_w; u++) {
            for (int v = 0; v < m_h; v++) {
                m_precomputedRayDistributions[At(u, v, sizes)] = GetRayDistribution(u, v, 0, m_l);
            }
        }


    }

    int* GetRayDistribution(int u, int v, int t1, int t2) {
        int* distribution = (int*)calloc(256 * 3, sizeof(int));
        int rsizes[] = {m_w, m_h};
        int dsizes[] = {256};

        for (int t = t1; t < t2; t++) {

            int b = (int)(m_realisation[At(u, v, t, rsizes)][0] * 255);
            int g = (int)(m_realisation[At(u, v, t, rsizes)][1] * 255);
            int r = (int)(m_realisation[At(u, v, t, rsizes)][2] * 255);

            distribution[At(b, 0, dsizes)] += 1;
            distribution[At(g, 0, dsizes)] += 1;
            distribution[At(r, 0, dsizes)] += 1;
        }
        
        return distribution;
    }

    int* GetRayDistribution(int u, int v) {
        int sizes[] = {m_w};
        return m_precomputedRayDistributions[At(u, v, sizes)];
    }

    // ** MEAN

    cv::Vec3d* m_precomputedRayMean;
    void PrecomputeRayMean () {
        m_precomputedRayMean = (cv::Vec3d*)calloc(m_w * m_h, sizeof(cv::Vec3d));
        int sizes[] = {m_w};

        #pragma omp parallel for
        for (int u = 0; u < m_w; u++) {
            for (int v = 0; v < m_h; v++) {
                m_precomputedRayMean[At(u, v, sizes)] = GetRayMean(u, v, 0, m_l);
            }
        }
    }

    cv::Vec3d GetRayMean(int u, int v, int t1, int t2) {
        cv::Vec3d mean(0, 0, 0);
        int sizes[] = {m_w, m_h};

        for (int t = t1; t < t2; t++) {
            mean += m_realisation[At(u, v, t, sizes)];
        }

        mean /= (double)(t2 - t1);
        return mean;
    }

    cv::Vec3d GetRayMean(int u, int v) {
        int sizes[] = {m_w};
        return m_precomputedRayMean[At(u, v, sizes)];
    }

    // ** VARIANCE

    cv::Vec3d* m_precomputedRayVariance;
    void PrecomputeRayVariance () {
        m_precomputedRayVariance = (cv::Vec3d*)calloc(m_w * m_h, sizeof(cv::Vec3d));
        int sizes[] = {m_w};

        #pragma omp parallel for
        for (int u = 0; u < m_w; u++) {
            for (int v = 0; v < m_h; v++) {
                m_precomputedRayVariance[At(u, v, sizes)] = GetRayVariance(u, v, 0, m_l);
            }
        }
    }

    cv::Vec3d GetRayVariance(int u, int v, int t1, int t2) {
        cv::Vec3d variance(0, 0, 0);
        int sizes[] = {m_w, m_h};

        cv::Vec3d meant1t2 = GetRayMean(u, v, t1, t2);

        for (int t = t1; t < t2; t++) {
            cv::Vec3d x = m_realisation[At(u, v, t, sizes)];
            cv::Vec3d diff = meant1t2 - x;
            diff[0] = diff[0] * diff[0];
            diff[1] = diff[1] * diff[1];
            diff[2] = diff[2] * diff[2];
            variance += diff;
        }

        variance /= (double)(t2 - t1);
        return variance;
    }

    cv::Vec3d GetRayVariance(int u, int v) {
        int sizes[] = {m_w};
        return m_precomputedRayVariance[At(u, v, sizes)];
    }
};

#endif