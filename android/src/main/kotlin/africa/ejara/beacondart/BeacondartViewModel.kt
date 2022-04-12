package africa.ejara.beacondart

import androidx.lifecycle.*
import it.airgap.beaconsdk.blockchain.substrate.data.SubstrateAccount
import it.airgap.beaconsdk.blockchain.substrate.data.SubstrateNetwork
import it.airgap.beaconsdk.blockchain.substrate.message.request.PermissionSubstrateRequest
import it.airgap.beaconsdk.blockchain.substrate.message.response.PermissionSubstrateResponse
import it.airgap.beaconsdk.blockchain.substrate.substrate
import it.airgap.beaconsdk.blockchain.tezos.data.TezosAccount
import it.airgap.beaconsdk.blockchain.tezos.data.TezosError
import it.airgap.beaconsdk.blockchain.tezos.data.TezosNetwork
import it.airgap.beaconsdk.blockchain.tezos.extension.from
import it.airgap.beaconsdk.blockchain.tezos.message.request.BroadcastTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.OperationTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.PermissionTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.SignPayloadTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.response.PermissionTezosResponse
import it.airgap.beaconsdk.blockchain.tezos.tezos
import it.airgap.beaconsdk.client.wallet.BeaconWalletClient
import it.airgap.beaconsdk.core.data.BeaconError
import it.airgap.beaconsdk.core.data.P2pPeer
import it.airgap.beaconsdk.core.data.Peer
import it.airgap.beaconsdk.core.message.BeaconMessage
import it.airgap.beaconsdk.core.message.BeaconRequest
import it.airgap.beaconsdk.core.message.ErrorBeaconResponse
import it.airgap.beaconsdk.transport.p2p.matrix.p2pMatrix
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

class BeacondartViewModel : ViewModel() {
// class BeacondartViewModel {
    private val _state: MutableLiveData<BeacondartPlugin.State> = MutableLiveData(BeacondartPlugin.State())
    val state: LiveData<BeacondartPlugin.State>
        get() = _state

    var beaconClient: BeaconWalletClient? = null
    private var awaitingRequest: BeaconRequest? = null

    fun onInit()
    {
        viewModelScope.launch {
            startBeacon()
        }
    }

    suspend fun startBeacon(): LiveData<Result<BeaconRequest>> = liveData {
        try {
            beaconClient = BeaconWalletClient("Ejara") {
                support(tezos(), substrate())
                use(p2pMatrix())
                ignoreUnsupportedBlockchains = true
            }
            checkForPeers()
            beaconClient?.connect()
                ?.onEach { result -> result.getOrNull()?.let { saveAwaitingRequest(it) } }
                ?.collect { emit(it) }

        } catch (e: Exception) {
            // result.error("exception", e.message, e.stackTrace)
            // onError(e)
        }
    }

    fun beginBeacon(): LiveData<Result<BeaconRequest>> = liveData {
        try {
            beaconClient = BeaconWalletClient("Ejara") {
                support(tezos(), substrate())
                use(p2pMatrix())
                ignoreUnsupportedBlockchains = true
            }
            checkForPeers()
            beaconClient?.connect()
                ?.onEach { result -> result.getOrNull()?.let { saveAwaitingRequest(it) } }
                ?.collect { emit(it) }

        } catch (e: Exception) {
            // result.error("exception", e.message, e.stackTrace)
            onError(e)
            throw e
        }
    }

    fun respondExample() {
        val request = awaitingRequest ?: return

        viewModelScope.launch {
            val response = when (request) {

                /* Tezos */

                is PermissionTezosRequest -> PermissionTezosResponse.from(request, exampleTezosAccount(request.network))
                is OperationTezosRequest -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
                is SignPayloadTezosRequest -> ErrorBeaconResponse.from(request, TezosError.SignatureTypeNotSupported)
                is BroadcastTezosRequest -> ErrorBeaconResponse.from(request, TezosError.BroadcastError)

                /* Substrate*/

                is PermissionSubstrateRequest -> PermissionSubstrateResponse.from(request, listOf(exampleSubstrateAccount(request.networks.first())))

                /* Others */
                else -> ErrorBeaconResponse.from(request, BeaconError.Unknown)
            }
            beaconClient?.respond(response)
            removeAwaitingRequest()
        }
    }

    fun addPeer(id: String, name: String, publicKey: String, relayServer: String, version: String) {
        val peer = P2pPeer(id = id, name = name, publicKey = publicKey, relayServer = relayServer, version = version)
        viewModelScope.launch {
            beaconClient?.addPeers(peer)
            checkForPeers()
        }
    }

    fun getPeers() : List<Peer> ? {
        var listPeers : List<Peer>? = null
        viewModelScope.launch {
            listPeers = beaconClient?.getPeers()!!

        }
        return listPeers;
    }

    fun removePeers() {
        viewModelScope.launch {
            beaconClient?.removeAllPeers()
            checkForPeers()
        }
    }

    fun removePeer(id: String) {

        viewModelScope.launch {
            val peers = beaconClient?.getPeers() // get subscribed peers
            val dApp = peers!!.find { it.id == id }
            if (dApp != null) {
                beaconClient?.removePeers(dApp)
            }
            checkForPeers()
        }
    }

    private suspend fun checkForPeers() {
        val peers = beaconClient?.getPeers()

        val state = _state.value ?: BeacondartPlugin.State()
        _state.postValue(state.copy(hasPeers = peers?.isNotEmpty() ?: false))
    }

    private fun checkForAwaitingRequest() {
        val state = _state.value ?: BeacondartPlugin.State()
        _state.postValue(state.copy(hasAwaitingRequest = awaitingRequest != null))
    }

    private fun saveAwaitingRequest(message: BeaconMessage) {
        awaitingRequest = if (message is BeaconRequest) message else null
        checkForAwaitingRequest()
    }

    private fun removeAwaitingRequest() {
        awaitingRequest = null
        checkForAwaitingRequest()
    }

    private fun onError(exception: Throwable) {
        exception.printStackTrace()
    }


    companion object {

        fun tezosAccount(publicKey: String, address: String, network: TezosNetwork): TezosAccount = TezosAccount(
            publicKey,
            address,
            network,
        )

        fun substrateAccount(publicKey: String, address: String,network: SubstrateNetwork): SubstrateAccount = SubstrateAccount(
            publicKey,
            address,
            network,
        )

        fun exampleTezosAccount(network: TezosNetwork): TezosAccount = TezosAccount(
            "edpkvL3FNBYHdDohfVu6XdtHiRGxmzymR7bKo4J1dAeAs23V8PkkKu",
            "tz1ajkyd4hg6gExtVHBUAD269T9VpxfR74om",
            network,
        )

        fun exampleSubstrateAccount(network: SubstrateNetwork): SubstrateAccount = SubstrateAccount(
            "724867a19e4a9422ac85f3b9a7c4bf5ccf12c2df60d858b216b81329df716535",
            "13aqy7vzMjuS2Nd6TYahHHetGt7dTgaqijT6Tpw3NS2MDFug",
            network,
        )
    }
}