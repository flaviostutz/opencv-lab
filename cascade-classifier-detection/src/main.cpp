#include <iostream>
#include <stdio.h>
#include <unistd.h>

#include "opencv2/objdetect.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"

using namespace std;
using namespace cv;

/** Function Headers */
void detectAndDisplay(Mat frame);

CascadeClassifier main_cascade;

int main(int argc, char *argv[]) {
    // int rc;

    if(argc < 2) {
        printf("Usage: video-detect [cascade xml file] [video file]\n\n");
        return -1;
    }
    
    printf("Loading Cascade... ");
    if(!main_cascade.load(argv[1])) {
        printf("--Error loading cascade\n");
        return -1;
    };
    printf("OK\n");
    
    printf("Loading video...\n");
    
    VideoCapture cap(argv[2]);
    if(!cap.isOpened()) {
        cout << "Cannot open the video file" << endl;
        return -1;
    }
    
    double count = cap.get(CV_CAP_PROP_FRAME_COUNT); //get the frame count
//    cap.set(CV_CAP_PROP_POS_FRAMES,count-1); //Set index to last frame
    namedWindow("video-detect",CV_WINDOW_AUTOSIZE);
    
    Mat frame;
    while(cap.read(frame)) {
        if( frame.empty()) {
            printf(" --No captured frame");
            break;
        }
        
        //-- 3. Apply the classifier to the frame
        detectAndDisplay(frame);
        if(waitKey(0) == 27) break;
    }

    return 0;
}

void detectAndDisplay(Mat frame) {
    std::vector<Rect> matches;
    Mat frame_gray;
    
    cvtColor( frame, frame_gray, COLOR_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );
    
    //-- Detect objects
    main_cascade.detectMultiScale(frame_gray, matches, 1.1, 2, 0|CASCADE_SCALE_IMAGE, Size(30, 30));
    
    for(size_t i = 0; i < matches.size(); i++) {
        Point center(matches[i].x + matches[i].width/2, matches[i].y + matches[i].height/2);
        rectangle(frame, matches[i], Scalar(255, 0, 0), 2);
    }
    //-- Show what you got
    imshow("video-detect", frame);
}

