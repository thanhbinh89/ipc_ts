#include "liveMedia.hh"
#include "BasicUsageEnvironment.hh"
   
char const* inputVideoFileName = "samples/video0.h264";
char const* inputAudioFileName = "samples/audio.aac";
char const* outputFileName = "samples/mux.ts";

void afterPlaying(void* clientData); // forward

UsageEnvironment* env;

int main(int argc, char** argv) {
  // Begin by setting up our usage environment:
  TaskScheduler* scheduler = BasicTaskScheduler::createNew();
  env = BasicUsageEnvironment::createNew(*scheduler);

  // Open the input file as a 'byte-stream file source':
  FramedSource* inputVideoSource = ByteStreamFileSource::createNew(*env, inputVideoFileName);
  if (inputVideoSource == NULL) {
    *env << "Unable to open file \"" << inputVideoFileName << "\" as a byte-stream file source\n";
    exit(1);
  }  

  FramedSource* inputAudioSource = ADTSAudioFileSource::createNew(*env, inputAudioFileName);
  if (inputAudioSource == NULL) {
    *env << "Unable to open file \"" << inputAudioFileName  << "\" as a byte-stream ADTS\n";
    exit(1); 
  }
  
  H264VideoStreamFramer* videoFramer = 
    H264VideoStreamFramer::createNew(*env, inputVideoSource, True/*includeStartCodeInOutput*/);
  ADTSAudioStreamDiscreteFramer* audioFrames =  
    ADTSAudioStreamDiscreteFramer::createNew(*env, inputAudioSource, "0A08");

  // Then create a filter that packs the H.264 video data into a Transport Stream:
  MPEG2TransportStreamFromESSource* tsFrames = MPEG2TransportStreamFromESSource::createNew(*env);  
  tsFrames->addNewVideoSource(videoFramer, 5/*mpegVersion: H.264*/);
  tsFrames->addNewAudioSource(audioFrames, 4/*mpegVersion: AAC*/);
  

  // Open the output file as a 'file sink':
  MediaSink* outputSink = FileSink::createNew(*env, outputFileName);
  if (outputSink == NULL) {
    *env << "Unable to open file \"" << outputFileName << "\" as a file sink\n";
    exit(1);
  }

  // Finally, start playing:
  *env << "Beginning to read...\n";
  outputSink->startPlaying(*tsFrames, afterPlaying, NULL);

  env->taskScheduler().doEventLoop(); // does not return

  return 0; // only to prevent compiler warning
}

void afterPlaying(void* /*clientData*/) {
  *env << "Done reading.\n";
  *env << "Wrote output file: \"" << outputFileName << "\"\n";
  exit(0);
}
