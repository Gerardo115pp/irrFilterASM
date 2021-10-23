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
    float audio_data[] = {2.36645044, 2.24270133, 1.90397508, 8.91339601, 7.07949785,
       4.40798942, 7.12211063, 4.63229018, 2.21389533};
    float filtered_data[10] = {0};

    irrFilterSSE(audio_data, filtered_data, 10);

    int test_passed = testIrrFilter(filtered_data, audio_data, 10);
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
