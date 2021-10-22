#include <stdio.h>
#include <stdlib.h>

extern void irrFilterSSE(float* audio_data, float* filtered_data, int length);

void printAudioData(float* audio_data, int length)
{
  int i;
  for (i = 0; i < length; i++)
  {
    printf("%f\n", audio_data[i]);
  }
}

int testIrrFilter(float* filter_data, float* audio_data, int length)
{
    float* correct_data = (float*)malloc(sizeof(float) * length);
    int test_result = 1;
    
    printf("correct - irrOutput\n\n");
    for (int i = 0; i < length; i++)
    {
        correct_data[i] = i > 0 ? (audio_data[i]*0.5) + (correct_data[i-1]*0.5) : audio_data[i]*0.5; ;
        printf("%d : %.5f - %.5f -> ", i, correct_data[i], filter_data[i]);
        if (correct_data[i] != filter_data[i])
        {
            printf("FAIL\n");
            test_result = 0;
        } else {
            printf("PASS\n");
        }
    }
    return test_result;
}

int main(int argc, char const *argv[])
{
    float audio_data[] = { 12.58669026, 12.08013572, 14.40115982,  9.66286285, 10.27243582, 12.61772494,
     6.41063247,  5.83784748, 14.10010153};
    float filtered_data[9] = {0};

    irrFilterSSE(audio_data, filtered_data, 9);

    int test_passed = testIrrFilter(filtered_data, audio_data, 9);
    if (test_passed)
    {
        printf("\n\nTest passed\n");
    }
    else
    {
        printf("\n\nTest failed\n");
    }
    return 0;
}
