// Copyright 2015 The go-pocc Authors
// This file is part of the go-pocc library.
//
// The go-pocc library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-pocc library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-pocc library. If not, see <http://www.gnu.org/licenses/>.

// Package poccapi implements the general Pocc API functions.
package poccapi

import (
	"context"
	"math/big"

	"github.com/pocc/go-pocc/accounts"
	"github.com/pocc/go-pocc/common"
	"github.com/pocc/go-pocc/core"
	"github.com/pocc/go-pocc/core/state"
	"github.com/pocc/go-pocc/core/types"
	"github.com/pocc/go-pocc/core/vm"
	"github.com/pocc/go-pocc/pocc/downloader"
	"github.com/pocc/go-pocc/poccdb"
	"github.com/pocc/go-pocc/event"
	"github.com/pocc/go-pocc/params"
	"github.com/pocc/go-pocc/rpc"
)

// Backend interface provides the common API services (that are provided by
// both full and light clients) with access to necessary functions.
type Backend interface {
	// general Pocc API
	Downloader() *downloader.Downloader
	ProtocolVersion() int
	SuggestPrice(ctx context.Context) (*big.Int, error)
	ChainDb() ethdb.Database
	EventMux() *event.TypeMux
	AccountManager() *accounts.Manager
	// BlockChain API
	SetHead(number uint64)
	HeaderByNumber(ctx context.Context, blockNr rpc.BlockNumber) (*types.Header, error)
	BlockByNumber(ctx context.Context, blockNr rpc.BlockNumber) (*types.Block, error)
	StateAndHeaderByNumber(ctx context.Context, blockNr rpc.BlockNumber) (*state.StateDB, *types.Header, error)
	GetBlock(ctx context.Context, blockHash common.Hash) (*types.Block, error)

	GetPocBlocks(ctx context.Context, blockPage rpc.BlockNumber, blockCnt uint64) ([]*types.BlockSummary, error)

	GetReceipts(ctx context.Context, blockHash common.Hash) (types.Receipts, error)
	GetTd(blockHash common.Hash) *big.Int
	GetEVM(ctx context.Context, msg core.Message, state *state.StateDB, header *types.Header, vmCfg vm.Config) (*vm.EVM, func() error, error)
	SubscribeChainEvent(ch chan<- core.ChainEvent) event.Subscription
	SubscribeChainHeadEvent(ch chan<- core.ChainHeadEvent) event.Subscription
	SubscribeChainSideEvent(ch chan<- core.ChainSideEvent) event.Subscription

	// TxPool API
	SendTx(ctx context.Context, signedTx *types.Transaction) error
	GetPoolTransactions() (types.Transactions, error)
	GetPoolTransaction(txHash common.Hash) *types.Transaction
	GetPoolNonce(ctx context.Context, addr common.Address) (uint64, error)
	Stats() (pending int, queued int)
	TxPoolContent() (map[common.Address]types.Transactions, map[common.Address]types.Transactions)
	SubscribeTxPreEvent(chan<- core.TxPreEvent) event.Subscription

	ChainConfig() *params.ChainConfig
	CurrentBlock() *types.Block
}

func GetAPIs(apiBackend Backend) []rpc.API {
	nonceLock := new(AddrLocker)
	return []rpc.API{
		{
			Namespace: "pocc",
			Version:   "1.0",
			Service:   NewPublicPoccAPI(apiBackend),
			Public:    true,
		}, {
			Namespace: "pocc",
			Version:   "1.0",
			Service:   NewPublicBlockChainAPI(apiBackend),
			Public:    true,
		}, {
			Namespace: "pocc",
			Version:   "1.0",
			Service:   NewPublicTransactionPoolAPI(apiBackend, nonceLock),
			Public:    true,
		}, {
			Namespace: "txpool",
			Version:   "1.0",
			Service:   NewPublicTxPoolAPI(apiBackend),
			Public:    true,
		}, {
			Namespace: "debug",
			Version:   "1.0",
			Service:   NewPublicDebugAPI(apiBackend),
			Public:    true,
		}, {
			Namespace: "debug",
			Version:   "1.0",
			Service:   NewPrivateDebugAPI(apiBackend),
		}, {
			Namespace: "pocc",
			Version:   "1.0",
			Service:   NewPublicAccountAPI(apiBackend.AccountManager()),
			Public:    true,
		}, {
			Namespace: "personal",
			Version:   "1.0",
			Service:   NewPrivateAccountAPI(apiBackend, nonceLock),
			Public:    false,
		},
	}
}
