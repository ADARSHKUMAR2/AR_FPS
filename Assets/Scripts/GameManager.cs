using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

namespace Vuforia
{
    public class GameManager : MonoBehaviour
    {

        public GameObject[] enemies;
        public Vector3 spawnValues;
        public float spawnWait;
        public float spawnMostWait;
        public float spawnLeastWait;
        public int startWait;
        public bool stop;
        int randEnemy;

        [SerializeField]
        private Camera cam;
        public GameObject Main_GameObject;
        private bool tapFire = false;
        private bool contFire = false;
        public GameObject bullet;
        private bool gun_ui = true;
        private float bulletSpeed= 1500f;
        private int speed= 5;
        public bool shoot=false;
        public float fireRate = 1;
        private float fireCoolDown = 0;
        void Start()
        {
            if (cam == null)
            {
                Debug.LogError("PlayerShoot: No Camera Referenced");
                this.enabled = false;
            }

            StartCoroutine(waitSpawner());
        }
        void Update()
        {
            if (!EventSystem.current.IsPointerOverGameObject())
            {
                //gun_ui = false;
                Debug.Log("Clicked on the UI");
            }


            
            int nbTouches = Input.touchCount;

            if (nbTouches > 0 && gun_ui == true)
            {
                for (int i = 0; i < nbTouches; i++)
                {
                    Touch touch = Input.GetTouch(i);

                    TouchPhase phase = touch.phase;

                  
                    //if (touch.phase != TouchPhase.Ended && touch.phase != TouchPhase.Canceled)
                    //{
                    //    print("Continuous Shoot");
                    //}

                    switch (phase)
                    {
                        case TouchPhase.Began:
                            //print("Tap Fire");

                            print("New touch detected at position " + touch.position + " , index " + touch.fingerId);
                            //obj.SetActive(true);
                            
                            break;

                        case TouchPhase.Moved:

                            if(Input.GetTouch(0).deltaPosition.x > 0)
                            {
                                print("Touch index " + touch.fingerId + " has moved by " + touch.deltaPosition);
                                //print("right");
                                cam.transform.Rotate(0, speed * Time.deltaTime, 0);
                            }
                            else
                            {
                                print("Touch index " + touch.fingerId + " has moved by " + touch.deltaPosition);
                                //print("left");
                                cam.transform.Rotate(0, -speed * Time.deltaTime, 0);
                            }
                            break;

                        case TouchPhase.Stationary:
                            print("Touch index " + touch.fingerId + " is stationary at position " + touch.position);
                            //obj.SetActive(false);
                            //print("Cont. Fire");
                            break;

                        case TouchPhase.Ended:
                            print("Touch index " + touch.fingerId + " ended at position " + touch.position);
                          
                            break;

                        case TouchPhase.Canceled:
                            print("Touch index " + touch.fingerId + " cancelled");
                            break;

                    }
                }
            }
         
            if(contFire==true && shoot==true)
            {
                GameObject tempBullet = Instantiate(bullet, cam.transform.position, cam.transform.rotation ) as GameObject;
                Rigidbody tempRigidBodyBullet = tempBullet.GetComponent<Rigidbody>();
                tempRigidBodyBullet.AddForce(tempRigidBodyBullet.transform.forward * bulletSpeed);
                Destroy(tempBullet, 1.7f);
                Debug.Log("Fire");
                
            }
        }

        IEnumerator waitSpawner()
        {
            yield return new WaitForSeconds(startWait);
            while (!stop)
            {
                randEnemy = Random.Range(0, 2);
                //Vector3 spawnPosition = new Vector3(Random.Range(-spawnValues.x, spawnValues.x), 1, Random.Range(-spawnValues.z, spawnValues.z));
                Vector3 spawnPosition = new Vector3(Random.Range(-14, 13), -1 , Random.Range(20, 32));
                Instantiate(enemies[randEnemy], spawnPosition + transform.TransformPoint(0, 0, 0), gameObject.transform.rotation);
                yield return new WaitForSeconds(spawnWait);
            }
        }

        private void OnCollisionEnter(Collision collision)
        {
            if(collision.gameObject.tag=="Enemy")
            {
                Destroy(collision.gameObject);
                Destroy(gameObject);
            }
        }

        
        public void Fire()
        {
            shoot = true;

            GameObject tempBullet = Instantiate(bullet, cam.transform.position, cam.transform.rotation) as GameObject;
            Rigidbody tempRigidBodyBullet = tempBullet.GetComponent<Rigidbody>();
            tempRigidBodyBullet.AddForce(tempRigidBodyBullet.transform.forward * bulletSpeed);
            Destroy(tempBullet, 1.7f);
            Debug.Log(tapFire);
            Debug.Log(shoot);
        }
        public void StopFire()
        {
            shoot = false;
        }

        public void TapFireGun()
        {
            contFire = false;
            tapFire = true;
        }

        public void ContFireGun()
        {
            tapFire = false;
            contFire = true;
        }

        public void Shoot()
        {
            if(tapFire==true && shoot==true)
            {

                Debug.Log("Tap Gun");
            }
        }
    }
}