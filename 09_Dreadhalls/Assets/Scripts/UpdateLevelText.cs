using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UpdateLevelText : MonoBehaviour
{
    public GameObject levelManager;

    public Text levelText;

    // Start is called before the first frame update
    void Start()
    {
        levelManager = GameObject.Find("WhisperSource");
        levelText.text = "Level: " + levelManager.GetComponent<Level>().currentLevel;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
