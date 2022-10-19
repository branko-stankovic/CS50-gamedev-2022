using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GrabPickups : MonoBehaviour {

	private AudioSource pickupSoundSource;
	public GameObject level;

	void Start() {
		level = GameObject.Find("WhisperSource");
	}

	void Awake() {
		pickupSoundSource = DontDestroy.instance.GetComponents<AudioSource>()[1];
	}

	void OnControllerColliderHit(ControllerColliderHit hit) {
		if (hit.gameObject.tag == "Pickup") {
			level.GetComponent<Level>().currentLevel++;
			pickupSoundSource.Play();
			SceneManager.LoadScene("Play");
		}
	}
}
