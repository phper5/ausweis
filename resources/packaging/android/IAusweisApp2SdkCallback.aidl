package com.governikus.ausweisapp2;

interface IAusweisApp2SdkCallback {
    void sessionIdGenerated(String pSessionId);
    void receive(String pJson);
    void sdkDisconnected();
}
