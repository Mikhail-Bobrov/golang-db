package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func main() {
	var kubeconfig *string
	var def_homedir = homedir.HomeDir()
	var def_kubeconfig = filepath.Join(def_homedir, ".kube", "config")
	if def_homedir != "" {
		kubeconfig = flag.String("kubeconfig", def_kubeconfig, "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()
	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		panic(err)
	}
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(fmt.Sprintf("Error creating Kubernetes client: %v", err))
	}
	list_deploy, err := clientset.AppsV1().Deployments("lottery").List(context.TODO(), metav1.ListOptions{LabelSelector: "app=api-gateway"})
	if err != nil {
		panic(err)
	}
	test := list_deploy.Items[0]
	test2 := test.Status
	test3 := list_deploy
	fmt.Println(list_deploy)
	fmt.Println("se4as bydet")
	fmt.Println(test2)
	fmt.Println("se4as bydet")
	fmt.Println(test3)
	factory := informers.NewSharedInformerFactory(clientset, 0)
	informer := factory.Core().V1().Pods().Informer()
	// dawdawd := factory.Apps().V1().Deployments().Informer()
	// dawdawd.AddEventHandler(cache.)
	// dawdawd.AddEventHandler(cache.ResourceEventHandlerFuncs{
	// 	AddFunc: func(obj interface{}) {
	// 		deployment := obj.(*appsv1.Deployment)
	// 		fmt.Printf("Deployment added: %s\n", deployment.Name)
	// 	},
	// 	UpdateFunc: func(oldObj, newObj interface{}) {
	// 		newDeployment := newObj.(*appsv1.Deployment)
	// 		fmt.Printf("Deployment updated: %s\n", newDeployment.Name)
	// 	},
	// 	DeleteFunc: func(obj interface{}) {
	// 		deployment := obj.(*appsv1.Deployment)
	// 		fmt.Printf("Deployment deleted: %s\n", deployment.Name)
	// 	},
	// })

	informer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc: func(obj interface{}) {
			pod := obj.(*corev1.Pod)
			fmt.Printf("Pod added: %s/%s\n", pod.Namespace, pod.Name)
		},
		DeleteFunc: func(obj interface{}) {
			pod := obj.(*corev1.Pod)
			fmt.Printf("Pod deleted: %s/%s\n", pod.Namespace, pod.Name)
		},
	})

	stopCh := make(chan struct{})
	defer close(stopCh)

	go informer.Run(stopCh)

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	<-sigCh
}
