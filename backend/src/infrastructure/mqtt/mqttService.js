const mqtt = require('mqtt');


// =========================================================
// CONFIGURATION MQTT
// =========================================================

const MQTT_BROKER = 'mqtt://test.mosquitto.org:1883';

const MQTT_TOPIC_DATA = 'calinlink/donnees';
const MQTT_TOPIC_ALERT = 'calinlink/alertes';


// =========================================================
// CLIENT MQTT
// =========================================================

let mqttClient = null;
let isFanAutoActivated = false;
let lastTempAlertTime = 0;


// =========================================================
// INITIALISATION MQTT
// =========================================================

function initMQTT(io) {

    console.log('');
    console.log('========================================');
    console.log('       CONNEXION MQTT');
    console.log('========================================');

    console.log(
        'Broker :',
        MQTT_BROKER
    );

    console.log(
        'Topic DATA :',
        MQTT_TOPIC_DATA
    );

    console.log(
        'Topic ALERT :',
        MQTT_TOPIC_ALERT
    );


    // =====================================================
    // CONNEXION AU BROKER
    // =====================================================

    mqttClient = mqtt.connect(
        MQTT_BROKER,
        {
            clientId:
                'calinlink-backend-' +
                Date.now(),

            clean: true,

            reconnectPeriod: 5000,

            connectTimeout: 10000
        }
    );


    // =====================================================
    // MQTT CONNECTÉ
    // =====================================================

    mqttClient.on(
        'connect',
        () => {

            console.log('');
            console.log(
                'MQTT Backend connecté !'
            );


            // ==============================================
            // ABONNEMENT AUX TOPICS
            // ==============================================

            mqttClient.subscribe(
                [
                    MQTT_TOPIC_DATA,
                    MQTT_TOPIC_ALERT
                ],
                (error) => {

                    if (error) {

                        console.error(
                            'Erreur abonnement MQTT :',
                            error
                        );

                        return;
                    }


                    console.log(
                        'Abonnement MQTT réussi !'
                    );

                    console.log(
                        'Écoute :',
                        MQTT_TOPIC_DATA
                    );

                    console.log(
                        'Écoute :',
                        MQTT_TOPIC_ALERT
                    );
                }
            );
        }
    );


    // =====================================================
    // MESSAGE MQTT REÇU
    // =====================================================

    mqttClient.on(
        'message',
        (topic, message) => {

            const messageString =
                message.toString();


            console.log('');
            console.log(
                '========================================'
            );

            console.log(
                '         MESSAGE MQTT REÇU'
            );

            console.log(
                '========================================'
            );

            console.log(
                'Topic :',
                topic
            );

            console.log(
                'Message :',
                messageString
            );


            // =================================================
            // DONNÉES CAPTEURS
            // =================================================

            if (
                topic === MQTT_TOPIC_DATA
            ) {

                try {

                    const data =
                        JSON.parse(
                            messageString
                        );


                    console.log(
                        'Données CâlinLink reçues :'
                    );

                    console.log(
                        data
                    );

                    // =========================================
                    // GESTION AUTOMATIQUE TEMPÉRATURE > 35°C
                    // =========================================
                    const temp = Number(data.temperature ?? data.temp ?? data.temperature_ambient);
                    if (!isNaN(temp)) {
                        if (temp > 25) {
                            // Message affiché au backend
                            console.log('');
                            console.log('🚨 ========================================================');
                            console.log(`🚨 ALERTE : Température élevée détectée (${temp} °C > 35 °C) !`);
                            console.log('🚨 Action : Activation automatique du ventilateur en cours...');
                            console.log('🚨 ========================================================');
                            console.log('');

                            // 1. Activer le ventilateur via MQTT (pour Wokwi / ESP32 sur GPIO 26)
                            publishMQTT('calinlink/commande/ventilateur', '1');
                            publishMQTT('calinlink/cmd/ventilateur', '1');
                            isFanAutoActivated = true;
                            data.ventilateur_actif = true;

                            // 2. Envoyer une alerte vers Flutter via Socket.IO
                            const now = Date.now();
                            if (now - lastTempAlertTime > 20000) {
                                lastTempAlertTime = now;
                                const alertData = {
                                    message: `Température trop élevée (${temp}°C) ! Le ventilateur a été activé automatiquement.`,
                                    timestamp: now,
                                    severity: 'critical'
                                };

                                if (io) {
                                    io.emit('calinlink:alert', alertData);
                                    console.log('Alerte de température élevée transmise à l\'application Flutter via Socket.IO');
                                }
                            }
                        } else if (temp <= 30 && isFanAutoActivated) {
                            console.log('');
                            console.log('✅ ========================================================');
                            console.log(`✅ Température stabilisée (${temp} °C <= 30 °C).`);
                            console.log('✅ Désactivation automatique du ventilateur.');
                            console.log('✅ ========================================================');
                            console.log('');

                            publishMQTT('calinlink/commande/ventilateur', '0');
                            publishMQTT('calinlink/cmd/ventilateur', '0');
                            isFanAutoActivated = false;
                            data.ventilateur_actif = false;
                        }
                    }

                    // =========================================
                    // ENVOI VERS SOCKET.IO
                    // =========================================

                    if (io) {

                        io.emit(
                            'calinlink:data',
                            data
                        );


                        console.log(
                            'Données envoyées à Flutter via Socket.IO'
                        );
                    }

                }
                catch (error) {

                    console.error(
                        'Erreur parsing JSON MQTT :',
                        error
                    );
                }
            }


            // =================================================
            // ALERTES
            // =================================================

            else if (
                topic === MQTT_TOPIC_ALERT
            ) {

                const alertData = {

                    message:
                        messageString,

                    timestamp:
                        Date.now()
                };


                console.log(
                    'Alerte CâlinLink :',
                    messageString
                );


                // =========================================
                // ENVOI VERS SOCKET.IO
                // =========================================

                if (io) {

                    io.emit(
                        'calinlink:alert',
                        alertData
                    );


                    console.log(
                        'Alerte envoyée à Flutter via Socket.IO'
                    );
                }
            }
        }
    );


    // =====================================================
    // ERREUR MQTT
    // =====================================================

    mqttClient.on(
        'error',
        (error) => {

            console.error(
                'Erreur MQTT Backend :',
                error
            );
        }
    );


    // =====================================================
    // RECONNEXION
    // =====================================================

    mqttClient.on(
        'reconnect',
        () => {

            console.log(
                'Reconnexion au broker MQTT...'
            );
        }
    );


    // =====================================================
    // OFFLINE
    // =====================================================

    mqttClient.on(
        'offline',
        () => {

            console.log(
                'Backend MQTT hors ligne'
            );
        }
    );


    // =====================================================
    // FERMETURE
    // =====================================================

    mqttClient.on(
        'close',
        () => {

            console.log(
                'Connexion MQTT fermée'
            );
        }
    );


    return mqttClient;
}


function publishMQTT(topic, message) {
    if (mqttClient && mqttClient.connected) {
        mqttClient.publish(topic, message, (err) => {
            if (err) {
                console.error(`Erreur publication MQTT sur ${topic} :`, err);
            } else {
                console.log(`Message MQTT publié sur ${topic} : ${message}`);
            }
        });
    } else {
        console.warn('Impossible de publier sur MQTT : client non connecté');
    }
}


// =========================================================
// EXPORT
// =========================================================

module.exports = {
    initMQTT,
    publishMQTT
};