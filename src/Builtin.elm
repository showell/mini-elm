module Builtin exposing (..)

import Array
import Basics
import Dict
import List
import Maybe
import Result
import Set
import String
import Tuple


hacks =
    let
        emptyArrayHack =
            Array.empty

        isEmptyArrayHack =
            Array.isEmpty

        lengthArrayHack =
            Array.length

        initializeArrayHack =
            Array.initialize

        repeatArrayHack =
            Array.repeat

        fromListArrayHack =
            Array.fromList

        getArrayHack =
            Array.get

        setArrayHack =
            Array.set

        pushArrayHack =
            Array.push

        toListArrayHack =
            Array.toList

        toIndexedListArrayHack =
            Array.toIndexedList

        foldrArrayHack =
            Array.foldr

        foldlArrayHack =
            Array.foldl

        filterArrayHack =
            Array.filter

        mapArrayHack =
            Array.map

        indexedMapArrayHack =
            Array.indexedMap

        appendArrayHack =
            Array.append

        sliceArrayHack =
            Array.slice

        toFloatBasicsHack =
            Basics.toFloat

        roundBasicsHack =
            Basics.round

        floorBasicsHack =
            Basics.floor

        ceilingBasicsHack =
            Basics.ceiling

        truncateBasicsHack =
            Basics.truncate

        maxBasicsHack =
            Basics.max

        minBasicsHack =
            Basics.min

        compareBasicsHack =
            Basics.compare

        notBasicsHack =
            Basics.not

        xorBasicsHack =
            Basics.xor

        modByBasicsHack =
            Basics.modBy

        remainderByBasicsHack =
            Basics.remainderBy

        negateBasicsHack =
            Basics.negate

        absBasicsHack =
            Basics.abs

        clampBasicsHack =
            Basics.clamp

        sqrtBasicsHack =
            Basics.sqrt

        logBaseBasicsHack =
            Basics.logBase

        eBasicsHack =
            Basics.e

        piBasicsHack =
            Basics.pi

        cosBasicsHack =
            Basics.cos

        sinBasicsHack =
            Basics.sin

        tanBasicsHack =
            Basics.tan

        acosBasicsHack =
            Basics.acos

        asinBasicsHack =
            Basics.asin

        atanBasicsHack =
            Basics.atan

        atan2BasicsHack =
            Basics.atan2

        degreesBasicsHack =
            Basics.degrees

        radiansBasicsHack =
            Basics.radians

        turnsBasicsHack =
            Basics.turns

        toPolarBasicsHack =
            Basics.toPolar

        fromPolarBasicsHack =
            Basics.fromPolar

        isNaNBasicsHack =
            Basics.isNaN

        isInfiniteBasicsHack =
            Basics.isInfinite

        identityBasicsHack =
            Basics.identity

        alwaysBasicsHack =
            Basics.always

        neverBasicsHack =
            Basics.never

        emptyDictHack =
            Dict.empty

        singletonDictHack =
            Dict.singleton

        insertDictHack =
            Dict.insert

        updateDictHack =
            Dict.update

        removeDictHack =
            Dict.remove

        isEmptyDictHack =
            Dict.isEmpty

        memberDictHack =
            Dict.member

        getDictHack =
            Dict.get

        sizeDictHack =
            Dict.size

        keysDictHack =
            Dict.keys

        valuesDictHack =
            Dict.values

        toListDictHack =
            Dict.toList

        fromListDictHack =
            Dict.fromList

        mapDictHack =
            Dict.map

        foldlDictHack =
            Dict.foldl

        foldrDictHack =
            Dict.foldr

        filterDictHack =
            Dict.filter

        partitionDictHack =
            Dict.partition

        unionDictHack =
            Dict.union

        intersectDictHack =
            Dict.intersect

        diffDictHack =
            Dict.diff

        mergeDictHack =
            Dict.merge

        singletonListHack =
            List.singleton

        repeatListHack =
            List.repeat

        rangeListHack =
            List.range

        mapListHack =
            List.map

        indexedMapListHack =
            List.indexedMap

        foldlListHack =
            List.foldl

        foldrListHack =
            List.foldr

        filterListHack =
            List.filter

        filterMapListHack =
            List.filterMap

        lengthListHack =
            List.length

        reverseListHack =
            List.reverse

        memberListHack =
            List.member

        allListHack =
            List.all

        anyListHack =
            List.any

        maximumListHack =
            List.maximum

        minimumListHack =
            List.minimum

        sumListHack =
            List.sum

        productListHack =
            List.product

        appendListHack =
            List.append

        concatListHack =
            List.concat

        concatMapListHack =
            List.concatMap

        intersperseListHack =
            List.intersperse

        map2ListHack =
            List.map2

        map3ListHack =
            List.map3

        map4ListHack =
            List.map4

        map5ListHack =
            List.map5

        sortListHack =
            List.sort

        sortByListHack =
            List.sortBy

        sortWithListHack =
            List.sortWith

        isEmptyListHack =
            List.isEmpty

        headListHack =
            List.head

        tailListHack =
            List.tail

        takeListHack =
            List.take

        dropListHack =
            List.drop

        partitionListHack =
            List.partition

        unzipListHack =
            List.unzip

        andThenMaybeHack =
            Maybe.andThen

        mapMaybeHack =
            Maybe.map

        map2MaybeHack =
            Maybe.map2

        map3MaybeHack =
            Maybe.map3

        map4MaybeHack =
            Maybe.map4

        map5MaybeHack =
            Maybe.map5

        withDefaultMaybeHack =
            Maybe.withDefault

        withDefaultResultHack =
            Result.withDefault

        mapResultHack =
            Result.map

        map2ResultHack =
            Result.map2

        map3ResultHack =
            Result.map3

        map4ResultHack =
            Result.map4

        map5ResultHack =
            Result.map5

        andThenResultHack =
            Result.andThen

        toMaybeResultHack =
            Result.toMaybe

        fromMaybeResultHack =
            Result.fromMaybe

        mapErrorResultHack =
            Result.mapError

        emptySetHack =
            Set.empty

        singletonSetHack =
            Set.singleton

        insertSetHack =
            Set.insert

        removeSetHack =
            Set.remove

        isEmptySetHack =
            Set.isEmpty

        memberSetHack =
            Set.member

        sizeSetHack =
            Set.size

        unionSetHack =
            Set.union

        intersectSetHack =
            Set.intersect

        diffSetHack =
            Set.diff

        toListSetHack =
            Set.toList

        fromListSetHack =
            Set.fromList

        mapSetHack =
            Set.map

        foldlSetHack =
            Set.foldl

        foldrSetHack =
            Set.foldr

        filterSetHack =
            Set.filter

        partitionSetHack =
            Set.partition

        isEmptyStringHack =
            String.isEmpty

        lengthStringHack =
            String.length

        reverseStringHack =
            String.reverse

        repeatStringHack =
            String.repeat

        replaceStringHack =
            String.replace

        appendStringHack =
            String.append

        concatStringHack =
            String.concat

        splitStringHack =
            String.split

        joinStringHack =
            String.join

        wordsStringHack =
            String.words

        linesStringHack =
            String.lines

        sliceStringHack =
            String.slice

        leftStringHack =
            String.left

        rightStringHack =
            String.right

        dropLeftStringHack =
            String.dropLeft

        dropRightStringHack =
            String.dropRight

        containsStringHack =
            String.contains

        startsWithStringHack =
            String.startsWith

        endsWithStringHack =
            String.endsWith

        indexesStringHack =
            String.indexes

        indicesStringHack =
            String.indices

        toIntStringHack =
            String.toInt

        fromIntStringHack =
            String.fromInt

        toFloatStringHack =
            String.toFloat

        fromFloatStringHack =
            String.fromFloat

        fromCharStringHack =
            String.fromChar

        consStringHack =
            String.cons

        unconsStringHack =
            String.uncons

        toListStringHack =
            String.toList

        fromListStringHack =
            String.fromList

        toUpperStringHack =
            String.toUpper

        toLowerStringHack =
            String.toLower

        padStringHack =
            String.pad

        padLeftStringHack =
            String.padLeft

        padRightStringHack =
            String.padRight

        trimStringHack =
            String.trim

        trimLeftStringHack =
            String.trimLeft

        trimRightStringHack =
            String.trimRight

        mapStringHack =
            String.map

        filterStringHack =
            String.filter

        foldlStringHack =
            String.foldl

        foldrStringHack =
            String.foldr

        anyStringHack =
            String.any

        allStringHack =
            String.all

        pairTupleHack =
            Tuple.pair

        firstTupleHack =
            Tuple.first

        secondTupleHack =
            Tuple.second

        mapFirstTupleHack =
            Tuple.mapFirst

        mapSecondTupleHack =
            Tuple.mapSecond

        mapBothTupleHack =
            Tuple.mapBoth
    in
    ()
