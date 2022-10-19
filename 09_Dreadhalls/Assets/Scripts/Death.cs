using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Death : MonoBehaviour
{
    public GameObject level;

    // Start is called before the first frame update
    void Start()
    {
        level = GameObject.Find("WhisperSource");
    }

    // Update is called once per frame
    void Update()
    {
        if (transform.position.y < -5) {
            level.GetComponent<Level>().currentLevel = 1;
            SceneManager.LoadScene("GameOver");
        }
    }
}
